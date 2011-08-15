$dimension = nil
def dimension(d)
  $dimension = d
  begin
    yield
  ensure
    $dimension = nil
  end
end
