
lambda { |stdout,stderr,_status|
  return :red   if /  🚫 failed/.match(stderr)
  return :green if /  ✅ passed/.match(stderr)
  return :amber
}
