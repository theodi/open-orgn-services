class DiversityMetrics
  
  @queue = :metrics

  extend MetricsHelper
  extend GoogleDriveHelper
    
  def self.perform
    {
      "diversity-gender" => gender
    }.each_pair do |metric, value|
      store_metric metric, DateTime.now, value
    end
  end

  def self.gender
    gender_sheet = metrics_worksheet("diversity", "Gender")    
    genders = {}
    (2..99).each do |row|
      gender = gender_sheet["C#{row}"]
      genders[gender.downcase] = row if gender.present?
    end
    data = {
      "total" => {},
      "teams" => {}
    }
    genders.each_pair do |gender, row|
      data["total"][gender] = gender_sheet["D#{row}"].to_i
    end
    ("E".."Z").each do |col|
      title = gender_sheet["#{col}1"].downcase
      if title != ""
        data["teams"][title] = {}
        genders.each_pair do |gender, row|
          data["teams"][title][gender] = gender_sheet["#{col}#{row}"].to_i
        end
      end
    end
    data
  end

end