def on_rb_update
  run_pazuzu = "ruby pazuzu.rb us-west-1"



  command_to_run = "#{run_pazuzu}"
  return command_to_run
end





guard :shell do
  watch(/(.*)\.rb$/) {|m| `#{on_rb_update}` }
end

