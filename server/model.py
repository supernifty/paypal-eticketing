import datetime
import decimal

from google.appengine.ext import db

class Profile(db.Model):
  '''extra user details'''
  owner = db.UserProperty()
  paypal_email = db.EmailProperty()  # for payment
  role = db.StringProperty( choices=( 'seller', 'buyer' ) )

  @staticmethod
  def from_user( u ):
    return Profile.all().filter( "owner = ", u ).get()

  @staticmethod
  def is_seller( u ):
    if u == None:
      return False
    profile = Profile.from_user( u )
    return profile != None and profile.role == 'seller'

class Item(db.Model):
  '''an item for sale'''
  owner = db.UserProperty()
  created = db.DateTimeProperty(auto_now_add=True)
  expiry = db.DateTimeProperty()
  title = db.StringProperty()
  price = db.IntegerProperty() # cents
  image = db.BlobProperty()
  enabled = db.BooleanProperty()

  def price_dollars( self ):
    return self.price / 100.0

  def price_decimal( self ):
    return decimal.Decimal( str( self.price / 100.0 ) )

  def time_remaining( self ):
    duration = self.expiry - datetime.datetime.now()
    if duration.days > 1:
      return "%i days" % duration.days
    if duration.days == 1:
      return "1 day"
    if duration.seconds > 7200:
      return "%i hours" % ( duration.seconds / 3600 )
    return "%i minutes!" % ( duration.seconds / 60 )

  @staticmethod
  def recent():
    return Item.all().filter( "enabled =", True ).order('-created').fetch(10)

  @staticmethod
  def soon():
    return Item.all().filter( "enabled =", True ).filter( "expiry >", datetime.datetime.now() ).order('expiry').fetch(10)
 
class Purchase(db.Model):
  '''a completed transaction'''
  item = db.ReferenceProperty(Item)
  owner = db.UserProperty()
  purchaser = db.UserProperty()
  created = db.DateTimeProperty(auto_now_add=True)
  status = db.StringProperty( choices=( 'NEW', 'CREATED', 'ERROR', 'CANCELLED', 'RETURNED', 'COMPLETED' ) )
  status_detail = db.StringProperty()
  secret = db.StringProperty() # to verify return_url
  code = db.StringProperty() # to validate
  debug_request = db.TextProperty()
  debug_response = db.TextProperty()
  paykey = db.StringProperty()
  shipping = db.TextProperty()

  def qr_code( self ):
    return "https://chart.googleapis.com/chart?chs=300x300&cht=qr&chl=%s&choe=UTF-8" % self.code
