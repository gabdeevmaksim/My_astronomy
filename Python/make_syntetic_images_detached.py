import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from astropy.table import Table, Column, hstack, vstack, unique
import random

import sys, os

def add_edges(tab):
    mask=tab['Phase']<0.2
    new_tab=tab[mask]
    new_tab['Phase']=new_tab['Phase']+1.

    final_tab=vstack([tab,new_tab])
    mask=tab['Phase']>0.8
    new_tab=tab[mask]
    new_tab['Phase']=new_tab['Phase']-1.
    final_tab=vstack([final_tab,new_tab])
    final_tab.sort('Phase')
    return final_tab


N=5000
#df=pd.read_csv("detach_spot_50p.csv")
# df1=pd.read_csv("/home/parimucha/Virtual/Random_dataset/merged/period/detached/detached_spots_period(0-1)_gaia.csv")
# df2=pd.read_csv("/home/parimucha/Virtual/Random_dataset/merged/period/detached/detached_spots_period(1-2)_gaia.csv")


df1=pd.read_csv("/home/parimucha/Virtual/Random_dataset/merged/period/detached/detached_nospots_period(0-1)_gaia.csv")
df2=pd.read_csv("/home/parimucha/Virtual/Random_dataset/merged/period/detached/detached_nospots_period(1-2)_gaia.csv")

# print(df2)
# sys.exit()

# df2 = df2.drop(columns='Unnamed 0')
df= pd.concat([df1, df2], axis=0)
df=df.sample(frac=1)

del df1
del df2

#
# df_s= pd.concat([df1, df2], axis=0)
# df_s=df_s.sample(frac=1)
#
# del df1
# del df2

# df= pd.concat([df1_s, df_n], axis=0)

# print(df)

# sys.exit()

#
df=df[df['period']<1.5]
df=df[df['t1/t2']>1.3]
df=df[df['inc']>50.]
df=df[df['pot1']<3.]
df=df[df['pot2']<4.5]
# df=df[df['r']>10.]

sample_df = df.sample(n=N, random_state=42)

print(sample_df)

# sys.exit()

out_dir='/home/parimucha/Virtual/GaiaLC/dataset/train/01/'


# 3 LEVEL NOISE
# DIFFERENT NUMBER OF point
# SHIFT OF ALL IN FLUX

phase=np.linspace(0.,1, 100, endpoint=True)
n=15000

for index, row in sample_df.iterrows():
    # print(row)
    flux_o=list(row[:100])
    noise1 = np.random.normal(0,0.01,100) #0.0, 0.01, 0.005
    flux=flux_o+noise1
    is_outlier=np.random.randint(0,5,1)
    if is_outlier>2:
        outlier_val=np.random.normal(0,0.3,1)
        outlier_pos=int(np.random.randint(0,100,1))
    else:
        outlier_pos=0
        outlier_val=0.

    flux[outlier_pos]=outlier_val+flux[outlier_pos]

    table=Table()
    table['Phase']=list(phase)
    table['Flux']=flux

    # remove some points randomly
    number_of_points=np.random.randint(60, 80)
    random_indices = np.random.choice(len(table), size=number_of_points, replace=False)
    # print(number_of_points)
    # print(random_indices)
    mask = np.ones(len(table), dtype=bool)  # Create a boolean mask
    mask[random_indices] = False  # Set mask to False for selected rows
    table = table[mask]
    # print(len(table))

    # random_flux_shift=np.random.uniform(0.1,0.5)
    # table['Flux']=table['Flux']-random_flux_shift

    tab=add_edges(table)

    # tab=table
    name=out_dir+str(n).zfill(5)+'.png'
    print(n, name)
    #print(flux_o, noise1)
    fig, ax = plt.subplots()
    fig.set_size_inches((3,3))
    ax.scatter(tab['Phase'], tab['Flux'], s=2, c='black')
    plt.ylim(top=1.1)
    plt.ylim(bottom=0.2)
    plt.xlim(-0.3, 1.3)
    plt.xticks([])
    plt.yticks([])

    # plt.show()
    plt.savefig(name, dpi=100, bbox_inches='tight',pad_inches = 0.1)
    plt.close()
    n=n+1
#





sys.exit()
dir='/home/parimucha/Virtual/GaiaLC/dataset/over_parameters/temperature/'

X = df

#df = df.reset_index()





def remove_points(table, number=15):
    phase=list(table['Phase'])
    remove_phase=random.sample(phase, number)
    mask =np.invert( [item in remove_phase for item in list(table['Phase'])])
    #mask=[True if table['Phase'] in remove_phase else False]
    final_tab=table[mask]


    return final_tab


tt=[]
ii=[]
qq=[]
pp=[]
n=0
for index, row in X.iterrows():
    flux_o=list(row[:50])
    t=row[50:]
    #t=row[55]/row[56]
    i=row[52]
    q=row[51]
    p=row[53]
    #print(t)
    #if t>=1.0 and t<1.03:
        #directory=dir+'1/'
    #if t>=1.03 and t<1.06:
        #directory=dir+'2/'
    #if t>=1.06 and t<1.09 :
        #directory=dir+'3/'
    #if t>=1.09 :
        #directory=dir+'4/'



    ##tt.append(t)
    ii.append(i)
    qq.append(q)
    pp.append(p)
    ###print(directory)
    #noise1 = np.random.normal(0,0.002,50)
    #table=Table()
    #table['Phase']=list(phase)
    #table['Flux']=flux_o
    #table['Noise']=noise1
    #table['Flux_Noise']=noise1+flux_o

    #number = random.randint(10, 15)
    #table=remove_points(table, number=number)
    #table=add_edges(table)

    #is_outlier=np.random.randint(0,5,1)
    #if is_outlier>3:
        #outlier_val=np.random.normal(0,0.5,1)
        #outlier_pos=int(np.random.randint(0,50,1))
    #else:
        #outlier_pos=0
        #outlier_val=0.

    #name=directory+str(n).zfill(5)+'.png'
    #print(n, name)

    #fig, ax = plt.subplots()
    #fig.set_size_inches((2,1))
    #ax.scatter(table['Phase'], table['Flux']+table['Noise'], s=5, c='black')
    #ax.set_yticklabels([])
    #ax.xaxis.set_tick_params(labelbottom=False)
    #ax.yaxis.set_tick_params(labelleft=False)
    #plt.tick_params(left = False)
    #plt.tick_params(bottom = False)

    ###ax.plot(phase, flux, c='black')
    ###plt.axis('off')
    #plt.ylim(top=1.01)
    #plt.ylim(bottom=0.5)
    ###plt.show()
    #plt.savefig(name, dpi=100, bbox_inches='tight',pad_inches = 0.1)
    #plt.close()
    #n=n+1



#print(max(pp))
#print(max(qq))
print(len(pp))
#plt.scatter(qq, pp)
plt.hist(pp, bins=5)
plt.hist(qq, bins=5)

plt.show()
sys.exit()


n=0
for index, row in X.iterrows():


    is_outlier=np.random.randint(0,5,1)
    if is_outlier>3:
        outlier_val=np.random.normal(0,0.5,1)
        outlier_pos=int(np.random.randint(0,50,1))
    else:
        outlier_pos=0
        outlier_val=0.

    #print(is_outlier, outlier_pos)

    #name=dir+str(n).zfill(5)+'_n.png'




    name=dir+str(n).zfill(5)+'_n.png'
    #name=dir+str(n).zfill(5)+'.png'

    #print(n, name)
    #flux=flux_o+noise1
    #flux[outlier_pos]=outlier_val+flux[outlier_pos]
    #fig, ax = plt.subplots()
    #fig.set_size_inches((1,1))
    #ax.scatter(phase, flux, s=5, c='black')
    #plt.ylim(top=1.01)
    ###ax.plot(phase, flux, c='black')
    ##plt.axis('off')
    ##plt.savefig(name, dpi=100, bbox_inches='tight',pad_inches = 0)
    #plt.show()
    #plt.close()
    ###n=n+1



    #name=dir+str(n).zfill(5)+'_n.png'
    ##name=dir+str(n).zfill(5)+'.png'

    #print(n, name)
    #flux=flux_o+noise2
    #flux[outlier_pos]=outlier_val+flux[outlier_pos]
    #fig, ax = plt.subplots()
    #fig.set_size_inches((2,2))
    #ax.scatter(phase, flux, s=5, c='black')
    ##ax.plot(phase, flux, c='black')
    #plt.axis('off')
    #plt.savefig(name, dpi=100, bbox_inches='tight',pad_inches = 0)
    ##plt.show()
    #plt.close()

    #sys.exit()


sys.exit()
