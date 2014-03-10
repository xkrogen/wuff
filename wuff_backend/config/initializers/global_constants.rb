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

# Possible user statuses in respect to an event. 
STATUS_NO_RESPONSE = 0
STATUS_ATTENDING = 1
STATUS_NOT_ATTENDING = -1

# Event notification types
NOTIF_NEW_EVENT = 1
NOTIF_DELETE_EVENT = 2
NOTIF_EDIT_EVENT = 3
NOTIF_FRIEND_ADD = 4


