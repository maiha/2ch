class HabtmSitesNegativeKeywords < Special::Migrations::Table
  habtm Ch2::Keyword, Ch2::Site, "ch2_habtm_sites_negative_keywords"
end
