install_package = -> packages do
  case
  when packages.respond_to?(:each_value)
    packages.each_value do |package|
      install_package.(package)
    end
  when packages.respond_to?(:each)
    packages.each do |package|
      install_package.(package)
    end
  else
    package packages
  end
end

install_package.(node.packages)
