require "google_drive"

class GoogleDrive::Mover
  @queue = :mover
  SPOOL_COLLECTION=ENV['GDRIVE_SPOOL_COLLECTION']
  TARGET_COLLECTION=ENV['GDRIVE_TARGET_COLLECTION']
  TARGET_KEY=ENV['GDRIVE_TARGET_KEY']
  USERNAME=ENV['GDRIVE_USERNAME']
  PASSWORD=ENV['GDRIVE_PASSWORD']

  def self.perform

    return if [SPOOL_COLLECTION,
               TARGET_COLLECTION,
               TARGET_KEY,
               USERNAME,
               PASSWORD].any?(&:empty?)

    session = GoogleDrive.login(USERNAME, PASSWORD)

    # get hold of root and relevant folders & docs
    root      = session.root_collection
    spool     = root.subcollection_by_title SPOOL_COLLECTION
    target    = root.subcollection_by_title TARGET_COLLECTION
    aggregate = session.spreadsheet_by_key TARGET_KEY

    # check if we have new files in the spool
    files = spool.files

    # remove them from the spool so future workers won't 
    # get in the way
    files.each do |file|
      spool.remove file
    end

    files.each do |file|
      # move the files to the target
      target.add file

      # change the title to be more descriptive
      ws = file.worksheets.first
      title = "#{ws[1,1]} - #{ws[2,1]} - #{ws[3,1]}"
      file.rename title

      # add it as a sheet to the aggregate doc
      target_ws = aggregate.add_worksheet title
      target_ws.update_cells 1, 1, ws.rows
      target_ws.save
    end
  end
end
