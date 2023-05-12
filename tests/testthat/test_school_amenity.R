require(testthat)
require(devtools)
require(catosmamenities)
context("Check that all detected amenities correspond to the expected types")
df <- get_all_schools("Palafrugell", plot = FALSE)

nrow_df_filtered <- df |> 
  filter(!(osm_amenity %in% c("school", "kindergarten", "music_school", "dancing_school", "language_school", NA_character_))) |> 
  nrow()

test_that("Only imports amenities which correspond to the expected types", {
  expected.value <- 0L
  expect_identical(expected.value, nrow_df_filtered)
})
