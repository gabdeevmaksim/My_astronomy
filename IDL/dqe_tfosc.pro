pro DQE_tfosc

DIR='e:\Observations\RTT150\T20201124\'
obj = read_table(DIR+'spec_um!.txt')
stan = read_table(DIR+'spec_rd!.txt')
stun_fl = read_table(DIR+'specHD_19455.txt')
star_fl_new = fltarr(2,N_elements(obj[0,*]))
t_exp=[1800*3,30]
obj[1,*]=obj[1,*]/t_exp[0] & stan[1,*]=stan[1,*]/t_exp[1]
par=spl_init(stun_fl[0,*],stun_fl[1,*])
star_fl_new[1,*]=spl_interp(stun_fl[0,*],stun_fl[1,*],par,obj[0,*])
star_fl_new[0,*]=obj[0,*]
plot, star_fl_new[0,*], star_fl_new[1,*]
plot, obj[0,*], obj[1,*] 
ys_stan_fl = lowess(star_fl_new[0,*], star_fl_new[1,*], 300, 3, 3)
ys_stan = lowess(stan[0,*], stan[1,*], 300, 3, 3)
cgplot, star_fl_new[0,*], obj[1,*]/ys_stan*ys_stan_fl*1e-13, color='red'
obj_ne = obj[1,*]/ys_stan*ys_stan_fl*1e-13
openw, 1, DIR+'spec_obj.dat'
for i=0,N_elements(obj[0,*])-1 do printf, 1, star_fl_new[0,i], obj_ne[i]
close, 1 
;cgplot, stan[0,*], stan[1,*], /overplot
end