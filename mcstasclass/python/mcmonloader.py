# rework of mcploatloader.py for plotting single monitor data

'''
functionality for loading mccode data into suitable data types,
and assembling it in a plot-friendly way.
'''
import glob
import re
from os.path import isfile, isdir, join, dirname, basename, splitext, exists
from os import walk
from decimal import Decimal
import numpy as np
import matplotlib.pyplot as plt
'''
McCode simulation output data types.
'''
class DataMcCode(object):
    ''' base type holding only the data object's title '''
    def __init__(self, *args, **kwargs):
        self.title = ''
        self.filepath = ''
        self.xlabel = ''
        self.ylabel = ''

    def __str__(self, *args, **kwargs):
        return self.title

    def _add_titles(self,ax):
        """ add titles to plot helper function"""
        ax.set_xlabel(self.xlabel)
        ax.set_ylabel(self.ylabel)
        ax.set_title(self.title)

class Data0D(DataMcCode):
    pass

class Data1D(DataMcCode):
    ''' 1d plots use this data type '''
    def __init__(self):
        super(Data1D, self).__init__()

        self.component = ''
        self.filename = ''
        self.title = ''
        self.xlabel = ''
        self.ylabel = ''

        self.xvar = ''
        self.xlimits = () # pair

        self.variables = []

        self.yvar = () # pair
        self.values = () # triplet
        self.statistics = ''

        # data references
        self.xvals = []
        self.yvals = []
        self.y_err_vals = []
        self.Nvals = []

    def clone(self):
        data = Data1D()

        data.filepath = self.filepath

        data.component = self.component
        data.filename = self.filename
        data.title = self.title
        data.xlabel = self.xlabel
        data.ylabel = self.ylabel

        data.xvar = self.xvar
        data.xlimits = self.xlimits

        data.variables = self.variables

        data.yvar = self.yvar
        data.values = self.values
        data.statistics = self.statistics

        # data references
        data.xvals = self.xvals
        data.yvals = self.yvals
        data.y_err_vals = self.y_err_vals
        data.Nvals = self.Nvals

        return data

    def get_stats_title(self):
        '''I=.... Err=... N=...; X0=...; dX=...;'''
        try:
            stitle = '%s=%e Err=%e N=%d; %s' % (self.yvar[0], self.values[0], self.values[1], self.values[2], self.statistics)
        except:
            stitle = '%s of %s' % (self.yvar[0], self.xvar)
        return stitle

    def __str__(self):
        return 'Data1D, ' + self.get_stats_title()

    def errorbar(self,ax=None,**kwargs):
        """
        plot an errorbar plot
        """
        if ax==None:
            fig, ax= plt.subplots()
        ax.errorbar(self.xvals,self.yvals,self.y_err_vals,**kwargs)
        self._add_titles(ax)

    def plot(self,ax=None,**kwargs):
        """plot an x y plot"""
        if ax==None:
            fig, ax= plt.subplots()
        ax.plot(self.xvals,self.yvals,**kwargs)
        self._add_titles(ax)

    def bin(self, binwidth):
        """
        rebins the data into bins of width binwidth
        """
        # Do we need to do type checking
        outcls = self.clone()
        xidx_sorted = np.argsort(self.xvals)
        x = np.array(self.xvals)[xidx_sorted]
        y = np.array(self.yvals)[xidx_sorted]
        e = np.array(self.y_err_vals)[xidx_sorted]

        # for storing the values to be combined
        xcombi = []
        ycombi = []
        ecombi = []
        # for storing the results
        xres=[]
        yres=[]
        eres=[]

        for idx, xval in enumerate(x):
            if len(xcombi)>0:
                if (xval-xcombi[0])>binwidth:
                    xres.append(np.sum(xcombi)/len(xcombi))
                    yres.append(np.sum(ycombi)/len(xcombi))
                    eres.append(np.sqrt(np.sum(np.array(ecombi)*np.array(ecombi)))/len(xcombi))
                    xcombi = [xval]
                    ycombi = [y[idx]]
                    ecombi = [e[idx]]
            else:
                xcombi.append(xval)
                ycombi.append(y[idx])
                ecombi.append(e[idx])
        # handle last point
        if len(xcombi)>0:
            xres.append(np.sum(xcombi)/len(xcombi))
            yres.append(np.sum(ycombi)/len(xcombi))
            eres.append(np.sqrt(np.sum(np.array(ecombi)*np.array(ecombi)))/len(xcombi))
        outcls.xvals = xres
        outcls.yvals = yres
        outcls.y_err_vals = eres
        outcls.title = outcls.title+"bined to {}".format(binwidth)
        outcls.xlimits = (np.min(xres),np.max(xres))
        return outcls


class Data2D(DataMcCode):
    ''' PSD data type '''
    def __init__(self):
        super(Data2D, self).__init__()

        self.component = ''
        self.filename = ''
        self.title = ''

        self.xlabel = ''
        self.ylabel = ''

        self.xvar = ''
        self.yvar = ''
        self.zvar = ''
        self.xylimits = () # quadruple

        self.values = () # triplet
        self.statistics = '' # quadruple
        self.signal = ''

        # data references
        self.zvals = []
        self.counts = []
        self.errors = []

    def get_stats_title(self):
        '''I=.... Err=... N=...; X0=...; dX=...;'''
        stitle = '%s=%e Err=%e N=%d' % (self.zvar, self.values[0], self.values[1], self.values[2])
        return stitle

    def __str__(self):
        return 'Data2D, ' + self.get_stats_title()

    def pcolor(self,ax=None,**kwargs):
        """ make a pcolor plot of a 2D mcstas monitor """
        if ax==None:
            fig, ax= plt.subplots()
        xvals,yvals=self.createxyvec()
        ax.pcolor(xvals,yvals,self.zvals,**kwargs)
        self._add_titles(ax)

    def createxyvec(self):
        """
        create a vector for the x and y coordinates from a 2D class
        """
        zarr = np.array(self.zvals)
        zshp = zarr.shape
        xvec = np.linspace(self.xylimits[0],self.xylimits[1],zshp[0]+1)
        yvec = np.linspace(self.xylimits[2],self.xylimits[3],zshp[0]+1)
        return xvec,yvec

    def cut(self,cutdir,cutcen,cutwidth,xlims=None):
        """ cut a 2D McStas data set into a 1D data set
            cutdir: must be 'x' or 'y'
            cutcen: center in other direction
            cutwidth: width in other direction
            xlims: limits in new x direction, default = None which uses full length

        """
        xylimits = self.xylimits
        xylimits_idx = np.zeros(4)
        xylimitsidx_dict = {'x':(0,1),'y':(2,3)}
        xyvar_dict = {'x':self.xvar,'y':self.yvar}
        xylabel_dict = {'x':self.xlabel,'y':self.ylabel}
        xylimits_dict = {'x':self.xylimits[:2],'y':self.xylimits[2:]}
        zaxes_dict = {'x':0,'y':1}
        int_dir = np.lib.arraysetops.setxor1d(cutdir,np.array(list(xyvar_dict.keys())))[0]

        data = Data1D()
        data.component = "cut from {}".format(self.filename)
        data.filename = self.filename
        data.title = "${}\pm{}$ in {}".format(cutcen,cutwidth/2,int_dir)
        data.xvar = xyvar_dict[cutdir]
        data.xlabel = xylabel_dict[cutdir]
        xvals,yvals = self.createxyvec()
        xyvals_dict = {'x':xvals,'y':yvals}
        zvals = np.array(self.zvals)
        if xlims == None:
            data.xlimits = xylimits_dict[cutdir]
            xmin_idx=0
            xmax_idx=-1
        else:
            xmin_idx = np.where(xyvals_dict[cutdir]<xlims[0])[0].max()
            xmax_idx = np.where(xyvals_dict[cutdir]>xlims[1])[0].min()
            data.xlimits = (xyvals_dict[cutdir][xmin_idx],xyvals_dict[cutdir][xmax_idx])
        xylimitsidx[xylimitsidx_dict[cutdir]]=[xmin_idx,xmax_idx]
        data.yvar = self.zvar
        cut_min_idx = np.where(xyvals_dict[int_dir] < (cutcen-cutwidth/2.0))[0].max()
        cut_max_idx = np.where(xyvals_dict[int_dir] > (cutcen+cutwidth/2.0))[0].min()
        xylimitsidx[xylimitsidx_dict[int_dir]] = [cut_min_idx,cut_max_idx]
        data.xvals = xyvals_dict[cutdir][xmin_idx:xmax_idx]
        data.yvals = np.sum(zvals[xylimitsidx[0]:xylimitsidx[1],xylimitsidx[2]:xylimits[idx3]],axis=zaxes_dict[cutdir])

        return data

'''
Utility funcitons for loading and parsing mccode output files
'''
freetext_pat = '.+'

def _parse_1D_monitor(text):
    ''' populates data fields of new Data1D object using the text from a mccode data file '''
    data = Data1D()

    try:
        # load essential header data
        '''# component: Ldetector'''
        m = re.search('\# component: ([\w\.]+)\n', text)
        data.component = m.group(1)
        '''# filename: Edet.dat'''
        m = re.search('\# filename: ([\-\+\w\.\,]+)\n', text)
        data.filename = m.group(1)
        '''# title: Wavelength monitor'''
        m = re.search('\# title: (%s)\n' % freetext_pat, text)
        data.title = m.group(1)
        '''# xlabel: Wavelength [AA]'''
        m = re.search('\# xlabel: (%s)\n' % freetext_pat, text)
        data.xlabel = m.group(1)
        '''# ylabel: Intensity'''
        m = re.search('\# ylabel: (%s)\n' % freetext_pat, text)
        data.ylabel = m.group(1)

        '''# xvar: L'''
        m = re.search('\# xvar: ([\w]+)\n', text)
        data.xvar = m.group(1)
        '''# xlimits: 5.5 6.5'''
        m = re.search('\# xlimits: ([\d\.\-\+e]+) ([\d\.\-\+e]+)\n', text)
        data.xlimits = (float(m.group(1)), float(m.group(2)))

        '''# yvar: (I,I_err)'''
        m = re.search('\# yvar: \(([\w]+),([\w]+)\)\n', text)
        data.yvar = (m.group(1), m.group(2))

        '''# values: 6.72365e-17 4.07766e-18 4750'''
        m = re.search('\# values: ([\d\-\+\.e]+) ([\d\-\+\.e]+) ([\d\-\+\.e]+)\n', text)
        data.values = (Decimal(m.group(1)), Decimal(m.group(2)), float(m.group(3)))
        '''# statistics: X0=5.99569; dX=0.0266368;'''
        m = re.search('\# statistics: X0=([\d\.\-\+e]+); dX=([\d\.\-\+e]+);\n', text)
        data.statistics = 'X0=%.2E; dX=%.2E;' % (Decimal(m.group(1)), Decimal(m.group(2)))

        # load the actual data
        lines = text.splitlines()
        xvals = []
        yvals = []
        y_err_vals = []
        Nvals = []
        for l in lines:
            if '#' in l:
                continue

            vals = l.split()
            xvals.append(float(vals[0]))
            yvals.append(float(vals[1]))
            y_err_vals.append(float(vals[2]))
            Nvals.append(float(vals[3]))

        data.xvals = xvals
        data.yvals = yvals
        data.y_err_vals = y_err_vals
        data.Nvals = Nvals

    except Exception as e:
        print('Data1D load error.')
        raise e

    return data

def _parse_2D_monitor(text):
    data = Data2D()

    ''' populates data fields using the text from a mccode data file '''
    try:
        # load essential header data
        '''# component: detector'''
        m = re.search('\# component: ([\w]+)\n', text)
        if m:
            data.component = m.group(1)
        else:
            data.component = "(no comp name)"
        '''# filename: PSD.dat'''
        m = re.search('\# filename: ([\-\+\w\.\,]+)\n', text)
        data.filename = m.group(1)
        '''# title: PSD monitor'''
        m = re.search('\# title: (%s)\n' % freetext_pat, text)
        data.title = m.group(1)

        '''# xlabel: X position [cm]'''
        m = re.search('\# xlabel: (%s)\n' % freetext_pat, text)
        data.xlabel = m.group(1)
        '''# ylabel: Y position [cm]'''
        m = re.search('\# ylabel: (%s)\n' % freetext_pat, text)
        data.ylabel = m.group(1)

        '''# xvar: X'''
        m = re.search('\# xvar: (%s)\n' % freetext_pat, text)
        data.xvar = m.group(1)
        '''# yvar: Y '''
        m = re.search('\# yvar: (%s)\n' % freetext_pat, text)
        data.yvar = m.group(1)

        '''# zvar: I '''
        m = re.search('\# zvar: (%s)\n' % freetext_pat, text)
        data.zvar = m.group(1)
        '''
        # xylimits: -30 30 -30 30
        # xylimits: 0 5e+06 0.5 100
        '''
        m = re.search('\# xylimits: ([\d\.\-\+e]+) ([\d\.\-\+e]+) ([\d\.\-\+e]+) ([\d\.\-\+e]+)([\ \d\.\-\+e]*)\n', text)
        data.xylimits = (float(m.group(1)), float(m.group(2)), float(m.group(3)), float(m.group(4)))

        '''# values: 6.72365e-17 4.07766e-18 4750'''
        m = re.search('\# values: ([\d\+\-\.e]+) ([\d\+\-\.e]+) ([\d\+\-\.e]+)\n', text)
        data.values = (Decimal(m.group(1)), Decimal(m.group(2)), float(m.group(3)))
        '''# statistics: X0=5.99569; dX=0.0266368;'''
        m = re.search('\# statistics: X0=([\d\.\+\-e]+); dX=([\d\.\+\-e]+); Y0=([\d\.\+\-e]+); dY=([\d\.\+\-e]+);\n', text)

        data.statistics = 'X0=%.2E; dX=%.2E; Y0=%.2E; dY=%.2E;' % (Decimal(m.group(1)), Decimal(m.group(2)), Decimal(m.group(3)), Decimal(m.group(4)))
        '''# signal: Min=0; Max=1.20439e-18; Mean=4.10394e-21;'''
        m = re.search('\# signal: Min=([\ \d\.\+\-e]+); Max=([\ \d\.\+\-e]+); Mean=([\ \d\.\+\-e]+);\n', text)
        data.signal = 'Min=%f; Max=%f; Mean=%f;' % (float(m.group(1)), float(m.group(2)), float(m.group(3)))

        '''# Data [detector/PSD.dat] I:'''
        '''# Events [detector/PSD.dat] N:'''
        '''# Errors [detecot/PSD.dat] I_err:'''
        lines = text.splitlines()

        t_flags={'data':False,'counts':False,'errors':False}
        for l in lines:
            if '# Data ' in l:
                t_flags={'data':True,'counts':False,'errors':False}

            if '# Events ' in l:
                t_flags={'data':False,'counts':True,'errors':False}

            if '# Errors ' in l:
                t_flags={'data':False,'counts':False,'errors':True}

            if np.any(list(t_flags.values())):
                try:
                    vals = [float(item) for item in l.strip().split()]
                    if t_flags['data']:
                        data.zvals.append(vals)
                    if t_flags['counts']:
                        data.counts.append(vals)
                    if t_flags['errors']:
                        data.errors.append(vals)
                except:
                    pass




    except Exception as e:
        print('Data2D load error.')
        raise e

    return data

def load_ascii_monitor(monfile):
    f = monfile
    if not f == 'No file':
        text = open(f).read()
        # determine 1D / 2D data

        m = re.search('\# type: (\w+)', text)
        typ = m.group(1)
        if typ == 'array_0d':
            print("load_monitor: Not loading 0d dataset %s" % monitorfile)
            data = Data0D()
        elif typ == 'array_1d':
            data = _parse_1D_monitor(text)
        elif typ == 'array_2d':
            data = _parse_2D_monitor(text)
        else:
            print('load_monitor: unknown data format %s' % typ)
            data = None
        data.filepath = f
        return data
    else:
        return Data0D()
    return data

def _get_filenames_from_mccodesim(mccodesim):
    dir = dirname(mccodesim)

    text = open(mccodesim).read()
    data_idx = text.find('begin data')
    filenames = []
    secs = text.split('begin data')
    for sec in secs[1:]:
        m = None
        for line in sec.splitlines():
            if m == None:
                m = re.search(r'filename: ([\w\.\,_\-+]+)\s*', line)
        if m:
            filenames.append(join(dir, m.group(1)))
        else:
            filenames.append('No file')
    return filenames
