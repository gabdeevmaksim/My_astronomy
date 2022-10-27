pro exampl
 
; First, generate some synthetic data

   npts = 200

   x  = dindgen(npts) * 0.1 - 10.                  ; Independent variable 

   yi = gauss1(x, [2.2D, 1.4, 3000.])              ; "Ideal" Y variable

   y  = yi + randomn(seed, npts) * sqrt(1000. + yi); Measured, w/ noise

   sy = sqrt(1000.D + y)                           ; Poisson errors



   ; Now fit a Gaussian to see how well we can recover

   p0 = [1.D, 1., 1000.]                   ; Initial guess (cent, width, area)

   p = mpfitfun('GAUSS1', x, y, sy, p0)    ; Fit a function

   print, p
  
end