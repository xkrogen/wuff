# Success return code
SUCCESS = 1
# Invalid name: Name must exist and have max length MAX_NAME_LENGTH
ERR_INVALID_NAME = -1 
# Invalid time: Time must be a valid time
ERR_INVALID_TIME = -10
# Invalid field: Generic, one of the fields is invalid. 
ERR_INVALID_FIELD = -6
# Generic error for an unsuccessful action
ERR_UNSUCCESSFUL = -7
# Invalid email: must be VALID_EMAIL_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
ERR_INVALID_EMAIL = -2
# Password cannot be longer than MAX_CREDENTIAL_LENGTH or shorter than MIN_PW_LENGTH
ERR_INVALID_PASSWORD = -3
# Email is not unique (i.e. exists already in database)
ERR_EMAIL_TAKEN = -4
# Cannot find the email/password pair in the database (i.e. login fail)
ERR_BAD_CREDENTIALS = -5
# Error when session token doesn’t match a valid logged in session. 
ERR_INVALID_SESSION = -11 
# Error when you don't have permission to do something 
# (i.e. you try to delete an event you don't own
ERR_INVALID_PERMISSIONS = -12

# Possible user statuses in respect to an event. 
STATUS_NO_RESPONSE = 0
STATUS_ATTENDING = 1
STATUS_NOT_ATTENDING = -1

# Event notification types
NOTIF_NEW_EVENT = 1
NOTIF_DELETE_EVENT = 2
NOTIF_EDIT_EVENT = 3
NOTIF_FRIEND_ADD = 4
NOTIF_COND_MET = 5
NOTIF_EVENT_STARTING = 6

# Condition types
# No condition set. 
COND_NONE = 0
# At least a certain number of other people will be attending the event
COND_NUM_ATTENDING = 1
# Any one of the users specified are attending the event.
COND_USER_ATTENDING_ANY = 2
# All of the users specified will be attending the event.
COND_USER_ATTENDING_ALL = 3

# The condition has been met. 
COND_MET = 0 
# The condition has not been met.
COND_NOT_MET = 1
