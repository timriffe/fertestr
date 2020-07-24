#' Reverse Survival Fertility Estimation Function
#'
#' Reverse Survival Fertility Estimation
#'
#' @param ages_c children ages (default 0:14)
#' @param pop_c children population matching ages_c vector
#' @param lx_c children survival function vector for single ages from 0 to 15
#' @param ages_w women ages (default c( 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65 ))
#' @param pop_women women population matching ages_w vector
#' @param lx_w women survival function matching ages_w vector
#' @param asfr age specific fertility rates for five-year age groups from 10-45 for current period
#' of estimation
#' @param asfr_15_prior standardized age specific fertility rates for five-year age groups from 10-45 for the
#' period of 15 years before the current inquiry period
#' @param q0_5 3 element vector for mortality probability between ages 0-4 for the period of estimation,
#' period 5 years prior to estimation period, and period 10 years prior to estimation period
#' @param q15_45f female adult mortality probability for the period of estimation,
#' period 5 years prior to estimation period, and period 10 years prior to estimation period
#' @param date_ref reference date of inquiry given in the following formats:
#' Y-m-d (4 digit year - 2 digit month - 2 digit day), Y-m (4 digit year - 2 digit month),
#' Y (4 digit year)
#'
#' @return data.frame with 2 elements: year (reference period of fertility estimation) and
#' TFR (indirect estimated total fertility rate) plus location name and ID if using wpp 2019 country data
#'
#' @export
#' @source
#'   Moultrie TA, RE Dorrington, AG Hill, K Hill, IM Timæus and B Zaba (eds). 2013.
#'   Tools for Demographic Estimation. Paris: International Union for the Scientific Study of
#'   Population. demographicestimation.iussp.org
#' @examples
#' ## reverse survival for 2008 Cambodia census data (Moultrie et al, 2013)
#' pop_c <-  c( 281260, 261320, 268410, 286810, 278990, 293760, 293490, 302060, 315970, 267190, 326980, 280260, 354120, 356920, 354830 )
#' pop_w <- c(  815930, 780320, 697160, 626430, 361650, 435880, 393760, 352520, 294280, 230200, 160590, NA )
#' lx_c <- c( 1.0000, 0.9320, 0.9275, 0.9228, 0.9165, 0.9125, 0.9110, 0.9094, 0.9079, 0.9063, 0.9048, 0.9032, 0.9017, 0.9001, 0.8986, 0.8970 )
#' lx_w <- c( 0.91381, 0.90989, 0.90492, 0.89798, 0.88893, 0.87596, 0.86029, 0.84188, 0.81791, 0.78472, 0.73735, 0.67316 )
#' q0_5 <-  c( 0.0683, 0.1008, 0.1189)
#' q15_45 <- c( 0.1946, 0.2290, 0.2674)
#' asfr <- c( 0.0000, 0.0418,0.1535, 0.1482, 0.1118, 0.0708, 0.0301, 0.0032 )
#' asfr_std <- asfr/(5 * sum(asfr) )
#' asfr_15prior <- c( 0.0000, 0.0533, 0.1974, 0.2144, 0.1836, 0.1332, 0.0676, 0.0134 )
#' asfr_std_15prior <- asfr_15prior/(5 * sum(asfr_15prior) )
#'
#' FertRevSurv( ages_c = 0:14, pop_c, ages_w = seq(10,65,5),
#' pop_w,  lx_c, lx_w, asfr_std, asfr_std_15prior, q0_5, q15_45,
#' date_ref = '2008-03-03')
#'
#' ## using Log-Quad model for estimation of lx_c and lx_w
#' FertRevSurv( ages_c = 0:14, pop_c, ages_w = seq(10,65,5),
#' pop_w,  lx_c, lx_w, asfr_std, asfr_std_15prior, q0_5, q15_45,
#' date_ref = '2008-03-03', logquad = T,
#' q0_5b = 0.075, q0_5f = 0.06, e0b = 65, e0f = 68)
#'
#'
#' ## reverse survival for 5 selected countries in 2010 using UN General mortality profile
#'
#' countries <- c( 32, 76, 380, 508, 752 ) # Argentina, Brazil, Italy, Mozambique, Sweden
#' FertRevSurv( location_list = countries, date_ref = 2010, lt_family = 'General' )

FertRevSurv0 <- function( ages1_c = 0:14, popx1_c,
                         ages5_w = seq( 10, 65, 5 ), popx5_w,
                         lx1_c, lx5_w,
                         asfr5 = c( 0, 0.017, 0.055, 0.057, 0.041, 0.022, 0.007, 0.002 ),
                         asfr5_15prior = NULL,
                         q0_5 = NULL, q15_45f = NULL,
                         date_ref ){

  year <- decimal_anydate( date_ref )

  datChildren <-
    data.frame( ages = ages1_c, pop_c = popx1_c )

  datWomen <-
    data.frame( ages = ages5_w, pop_w = popx5_w )

  fertPattern <-
    data.frame(
      age = seq( 10, 45, 5 ),
      asfr_std_ref = asfr / ( 5 * sum( asfr ) ),
      asfr_std_15prior = asfr / sum( asfr )
      )

  if( !is.null( asfr_std_15prior ) ){
    fertPattern$asfr_std_15prior <-  c( asfr_std_15prior )
    }

  lxChildren_std <-
    data.frame(
      age = 0:15,
      lx_std = lx1_c
      )

  lxWomen_std <-
    data.frame(
      age = ages5_w,
      lx_std = lx5_w
      )

  print( paste0( 'Reverse Survival Fertility Estimation - Reference date: ',
                 substr( lubridate::date_decimal( year ), 1, 10 ) ) )

  revSurvTFR <- revSurvMain( year,
                             datWomen, lxWomen_std, q15_45f,fertPattern,
                             datChildren, lxChildren_std, q0_5 )

  return( revSurvTFR )

}

# pop_c <-  c( 281260, 261320, 268410, 286810, 278990, 293760, 293490, 302060, 315970, 267190, 326980, 280260, 354120, 356920, 354830 )
# pop_w <- c(  815930, 780320, 697160, 626430, 361650, 435880, 393760, 352520, 294280, 230200, 160590, NA )
# lx_c <- c( 1.0000, 0.9320, 0.9275, 0.9228, 0.9165, 0.9125, 0.9110, 0.9094, 0.9079, 0.9063, 0.9048, 0.9032, 0.9017, 0.9001, 0.8986, 0.8970 )
# lx_w <- c( 0.91381, 0.90989, 0.90492, 0.89798, 0.88893, 0.87596, 0.86029, 0.84188, 0.81791, 0.78472, 0.73735, 0.67316 )
# q0_5 <-  c( 0.0683, 0.1008, 0.1189)
# q15_45f <- c( 0.1946, 0.2290, 0.2674)
# asfr <- c( 0.0000, 0.0418,0.1535, 0.1482, 0.1118, 0.0708, 0.0301, 0.0032 )
# asfr_15prior <- c( 0.0000, 0.0533, 0.1974, 0.2144, 0.1836, 0.1332, 0.0676, 0.0134 )
#
# FertRevSurv0( ages1_c = 0:14, popx1_c = pop_c,
#               ages5_w = seq( 10, 65, 5 ), popx5_w = pop_w,
#               lx1_c = lx_c, lx5_w = lx_w,
#               asfr5 = asfr,
#               asfr5_15prior = asfr_15prior,
#               q0_5 = q0_5, q15_45f = q15_45f,
#               date_ref = '2008-03-03' )

# using log-quadratic estimated survival functions
ltb <- SingleAgeLogQuadLT( q15_45 = 0.20, q0_5 = 0.07 )
ltf <- SingleAgeLogQuadLT( q15_45 = 0.19, q0_5 = 0.05, sex = 'female' )

lx_w <- ltf[ ltf$x %in% seq( 10, 65, 5 ), ]$lx
lx_c <- ltf[ ltf$x %in% seq( 0, 15 ), ]$lx

FertRevSurv0( ages1_c = 0:14, popx1_c = pop_c,
              ages5_w = seq( 10, 65, 5 ), popx5_w = pop_w,
              lx1_c = lx_c, lx5_w = lx_w,
              asfr5 = asfr,
              asfr5_15prior = asfr_15prior,
              q0_5 = q0_5, q15_45f = q15_45f,
              date_ref = '2008-03-03' )

# using model life table
lx_w <- find_mlt( lt_family = 'General', e0 = 69,
                  ages = seq( 10, 65, 5 ), sex = 'female' )$lx_std
lx_c <- find_mlt( lt_family = 'General', e0 = 67,
                  ages = seq( 0, 15 ), sex = 'both' )$lx_std

FertRevSurv0( ages1_c = 0:14, popx1_c = pop_c,
              ages5_w = seq( 10, 65, 5 ), popx5_w = pop_w,
              lx1_c = lx_c, lx5_w = lx_w,
              asfr5 = asfr,
              asfr5_15prior = asfr_15prior,
              q0_5 = q0_5, q15_45f = q15_45f,
              date_ref = '2008-03-03' )