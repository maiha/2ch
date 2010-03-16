class HabtmSitesPositiveKeywords < Special::Migrations::Table
  habtm Ch2::Keyword, Ch2::Site, "ch2_habtm_sites_positive_keywords"
end
