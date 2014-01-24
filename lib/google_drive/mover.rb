require "google_drive"

class GoogleDrive::Mover
  @queue = :mover
  SPOOL_COLLECTION=ENV['GAPPS_FINANCE_SPOOL_COLLECTION']
  TARGET_COLLECTION=ENV['GAPPS_FINANCE_TARGET_COLLECTION']
  TARGET_KEY=ENV['GAPPS_FINANCE_TARGET_KEY']
  USERNAME=ENV['GAPPS_USER_EMAIL']
  PASSWORD=ENV['GAPPS_PASSWORD']

  def self.perform

    # return immediately if we're missing some configuration
    return unless have_credentials?

    work_on(spool.files).each do |file|
      # move the files to the target collection
      target.add(file)

      # change the title to be more descriptive
      file.rename working_title(file)

      # add the file as a worksheet to the aggregate spreadsheet
      add_to_aggregate_as_ws(file)
    end
  end

  private

  def self.have_credentials?
   [SPOOL_COLLECTION,
    TARGET_COLLECTION,
    TARGET_KEY,
    USERNAME,
    PASSWORD].none? do |e|
      e.nil? || e.empty?
    end
  end

  # work_on
  #
  # remove files from the spool so future workers won't 
  # get in the way
  #
  # :files - the google drive files to work on
  #
  def self.work_on(files) 
    files.each do |file|
      spool.remove file
    end

    return files
  end

  # working_title
  #
  # return a significative title for the current spreadsheet.
  # It assumes the file is a spreadsheet and it's in the 
  # Xero export format.
  # It returns a string composed of the first three columns
  # of the first row in the first worksheet.
  #
  # file - the file from which to extract the title
  #
  def self.working_title(file)
    ws = file.worksheets.first
    "#{ws[1,1]} - #{ws[2,1]} - #{ws[3,1]}"
  end

  # add_to_aggregate_as_ws
  #
  # creates a new worksheet in the aggregate spreadsheet and
  # copies in the contents from the first worksheet of the 
  # specified file.
  #
  def self.add_to_aggregate_as_ws(file)
    # add the file as a sheet to the aggregate doc
    target_ws = aggregate.add_worksheet working_title(file)

    ws = file.worksheets.first
    target_ws.update_cells 1, 1, ws.rows
    target_ws.save
  end

  # session - returns the GoogleDrive session
  #
  def self.session
    @session ||= GoogleDrive.login(USERNAME, PASSWORD)
  end

  # root - returns the root collection for this GDrive account
  #
  def self.root
    @root ||= session.root_collection
  end

  # spool - returns the spool collection for this GDrive account
  #
  # this is where the worker expects to find the spreadsheets
  # exported from Xero.
  #
  def self.spool
    @spool ||= root.subcollection_by_title SPOOL_COLLECTION
  end

  # target - returns the target collection for this GDrive account
  #
  # this is the collection to which the processed files will be copied
  #
  def self.target
    @target ||= root.subcollection_by_title TARGET_COLLECTION
  end

  # aggregate - the aggregated spreadsheet
  #
  # this is the spreadsheet to which data coming from the individual exports
  # will be copied by the worker
  #
  def self.aggregate
    @aggregate ||= session.spreadsheet_by_key TARGET_KEY
  end
end
