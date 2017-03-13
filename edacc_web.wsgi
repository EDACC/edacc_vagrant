import site, sys, os
site.addsitedir('/srv/edacc_web_env/lib/python2.7/site-packages')
sys.path.append('/srv/edacc_web')
sys.path.append('/srv/edacc_web/edacc')
os.environ['PYTHON_EGG_CACHE'] = '/tmp'
os.environ['DISPLAY'] = ':1'
sys.stdout = sys.stderr
from edacc.web import app as application

