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

    def __str__(self, *args, **kwargs):
        return self.title

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

    def errorbar(self,ax=None):
        """
        plot an errorbar plot
        """
        if ax==None:
            fig, ax= plt.subplots()
        ax.errorbar(self.xvals,self.yvals,self.y_err_vals)
        ax.set_xlabel(self.xlabel)
        ax.set_ylabel(self.ylabel)
        ax.set_title(self.title)
    def bin(self, binwidth):
        """
        rebins the data into bins of width binwidth
        """
        # Do we need to do type checking
        outcls = self.clone()
        xidx_sorted = np.argsort(self.xvals)
        x = self.xvals[xidx_sorted]
        y = self.yvals[xidx_sorted]
        e = self.y_err_vals[xidx_sorted]

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
                if (x-xcombi[0])>binwidth:
                    xres.append(np.sum(xcombi)/len(xcombi))
                    yres.append(np.sum(ycombi)/len(xcombi))
                    eres.append(np.sqrt(np.sum(ecombi*ecombi))/len(xcombi))
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
            eres.append(np.sqrt(np.sum(ecombi*ecombi))/len(xcombi))
        outcls.xvals = xres
        outcls.yvals = yres
        outcls.y_err_vals = eres
        outcls.title = title+"bined to {}".format(binwidth)
        outcls.xlimits = (np.min(xres),np.max(xres))
return outcls



    def plot(self):
        "plot an x y plot"

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

    def get_stats_title(self):
        '''I=.... Err=... N=...; X0=...; dX=...;'''
        stitle = '%s=%e Err=%e N=%d' % (self.zvar, self.values[0], self.values[1], self.values[2])
        return stitle

    def __str__(self):
        return 'Data2D, ' + self.get_stats_title()


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
        data.xlimits = (float(m.group(1)), float(m.group(2)), float(m.group(3)), float(m.group(4)))

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
        lines = text.splitlines()
        dat = True
        events = False
        for l in lines:
            if '# Data ' in l:
                dat = True
                continue

            if '# Events ' in l:
                dat = False
                events = True
                continue

            if '# Errors ' in l:
                # NOTE: error values are not loaded
                dat = False
                events = False
                continue

            if dat:
                try:
                    vals = [float(item) for item in l.strip().split()]
                    data.zvals.append(vals)
                except:
                    pass
            if events:
                try:
                    vals = [float(item) for item in l.strip().split()]
                    data.counts.append(vals)
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
