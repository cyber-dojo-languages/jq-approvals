
lambda { |stdout,stderr,_status|
  return :red   if /  failed/.match(stdout)
  return :green if /  passed/.match(stdout)
  return :amber
}
