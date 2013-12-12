require "full_house/version"
require "open-uri"
require "json"
require "csv"

module FullHouse
  class Parser

    def self.parse_and_output
      nycb = parse_nycb
      bam = parse_bam
    end

    def self.parse_nycb
      start = DateTime.now
      results = []
      base_url = "http://www.nycballet.com/syos/services/seateditem/"
      nycb_peformances = [{ :perf => 3588, :date => '2013-12-13', :hour => '20'}, 
        {:perf => 3589, :date => '2013-12-14', :hour => 14}, {:perf => 3590, :date => '2013-12-14', :hour => 20},
        {:perf => 3591, :date => '2013-12-15', :hour => 13}, {:perf => 3592, :date => '2013-12-18', :hour => 19}, 
        {:perf => 3593, :date => '2013-12-19', :hour => 19}, {:perf => 3594, :date => '2013-12-20', :hour => 20},
        {:perf => 3595, :date => '2013-12-21', :hour => 14}, {:perf => 3596, :date => '2013-12-21', :hour => 20}, 
        {:perf => 3597, :date => '2013-12-22', :hour => 17}, {:perf => 3598, :date => '2013-12-23', :hour => 14},
        {:perf => 3599, :date => '2013-12-23', :hour => 19}]
      nycb_peformances.each do |nycb|
        response = JSON.parse(open(base_url+nycb[:perf].to_s).read)
        response["day"] = start.day
        response["hour"] = start.hour
        response["perf_id"] = nycb[:perf]
        response["perf_date"] = nycb[:date]
        response["perf_hour"] = nycb[:hour]
        results << response
      end
      CSV.open("nycb_#{start.day}_#{start.hour}.csv", "w", :write_headers=> true, :headers => ["day_checked","hour_checked","performance_id","performance_date","performance_hour","seat_type","price_range","seats"]) do |csv|
        results.each do |result|
          result['sections'].each do |section|
            csv << [result["day"], result["hour"], result["perf_id"], result["perf_date"], result["perf_hour"], section["name"], section["price"], section['message']]
          end
        end
      end
    end

    def self.parse_bam
      start = DateTime.now
      results = []
      base_url = "http://commerce.bam.org/services/SYOS/SeatsSections.ashx?performanceNumber="
      bam_performances = [{ :perf => 8102, :date => '2013-12-13', :hour => '19'}, 
        {:perf => 8104, :date => '2013-12-14', :hour => 14}, {:perf => 8105, :date => '2013-12-14', :hour => 19},
        {:perf => 8106, :date => '2013-12-15', :hour => 13}, {:perf => 8107, :date => '2013-12-15', :hour => 18}, 
        {:perf => 8108, :date => '2013-12-18', :hour => 19}, {:perf => 8109, :date => '2013-12-19', :hour => 19},
        {:perf => 8110, :date => '2013-12-20', :hour => 19}, {:perf => 8111, :date => '2013-12-21', :hour => 14}, 
        {:perf => 8112, :date => '2013-12-21', :hour => 19}, {:perf => 8113, :date => '2013-12-22', :hour => 13},
        {:perf => 8114, :date => '2013-12-22', :hour => 18}]
      bam_performances.each do |bam|
        response = JSON.parse(open(base_url+bam[:perf].to_s).read)
        response.each do |r|
          r["day"] = start.day
          r["hour"] = start.hour
          r["perf_id"] = bam[:perf]
          r["perf_date"] = bam[:date]
          r["perf_hour"] = bam[:hour]
        end
        results << response
      end
      CSV.open("bam_#{start.day}_#{start.hour}.csv", "w", :write_headers=> true, :headers => ["day_checked","hour_checked","performance_id","performance_date","performance_hour","seat_type","price_range","seats"]) do |csv|
        results.flatten.each do |result|
          csv << [result["day"], result["hour"], result["perf_id"], result["perf_date"], result["perf_hour"], result["ScreenDescription"], result["MinPrice"].to_s+"-"+result["MaxPrice"].to_s, result['AvailableSeats']]
        end
      end
    end
  end
end