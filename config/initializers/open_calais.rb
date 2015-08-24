OPEN_CALAIS_MAX_DAILY_CALLS = 50000
OPEN_CALAIS_KEY = "open_calais_daily_calls"

# Create AppConstant for open calais if we do not have one yet to keep track of daily calls
if AppConstant.value(OPEN_CALAIS_KEY).nil?
  AppConstant.replace(OPEN_CALAIS_KEY, 0)
end