class WebfaceErrorReportController < ApplicationController

  def report
    puts "**********************************"
    puts "Frontend error detected. Please make sure you redefine this action\n" +
         "to actually report this error to something like Sentry!\n" +
         "below are the params that were sent by Webface Logmaster:"
    p params
    puts "**********************************"
  end

end
