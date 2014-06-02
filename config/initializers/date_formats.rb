Time::DATE_FORMATS.merge!(
  :wday_date_month => lambda { |time| time.strftime("%a, %b #{time.day.ordinalize}") }
)
