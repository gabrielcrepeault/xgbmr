#' Simulated data from an Individual claims history simulation machine
#'
#' @description dataset that contains simulated individual claims obtained through
#' a Neural Network developped by Gabrielli & Wüthrich (2018).
#'
#' @format R object of class `data.frame` with 37190 rows and 32 columns :
#' \describe{
#' \item{ClNr}{Artificial Clainumber, 1 to 37190}
#' \item{LoB}{Line of business, 1 to 4}
#' \item{cc}{Claims code, categorical}
#' \item{AY}{Accident Year, 1994 to 2005}
#' \item{AQ}{Accident Quarter, 1 to 4}
#' \item{age}{Age of the insured, categorical}
#' \item{inj_part}{Injured part, categorical}
#' \item{RepDel}{Reporting Delay}
#' \item{Pay<xx>}{Incremental Payment. A column for each developpement year i, i = 0, ..., 11}
#' \item{Open<xx>}{Status of claim (1 = Open, 0 = Closed). A column for each developpement year i, i = 0, ..., 11}
#' }
#' @source Gabrielli, A., & V Wüthrich, M. (2018). An individual claims history simulation machine. Risks, 6(2), 29.
"SimulatedIndClaims"
