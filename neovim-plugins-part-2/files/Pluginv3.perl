sub file_to_package_name($path) {
  $path
    =~ s#^(.*/)?lib/##r
    =~ s#^/##r
    =~ s#/#::#rg
    =~ s#\.p[ml]$##r;
}
