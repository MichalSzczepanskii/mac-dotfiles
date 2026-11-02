# ng serve memory settings for every Angular project on this Mac (#84).
# NG_BUILD_PARALLEL_TS=0: peak RAM 7.3 -> 5.3 GB. Drop it if the A/B shows a slower warm .ts rebuild.
# NG_HMR_CSTYLES=1: .scss rebuild 9 -> 0.5 s.
# Measuring rebuild time? Run both variants: env -u NG_BUILD_PARALLEL_TS -u NG_HMR_CSTYLES npm start
export NG_BUILD_PARALLEL_TS=0 NG_HMR_CSTYLES=1
