import unittest
import os
import testLib

class TestUser(testLib.RestTestCase):

    # Success return code
    SUCCESS = 1
    # Invalid name: must be VALID_NAME_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
    ERR_INVALID_NAME = -1
    # Invalid email: must be VALID_EMAIL_REGEX format; cannot be empty; cannot be longer than MAX_CREDENTIAL_LENGTH
    ERR_INVALID_EMAIL = -2
    # Password cannot be longer than MAX_CREDENTIAL_LENGTH or shorter than MIN_PW_LENGTH
    ERR_INVALID_PASSWORD = -3
    # Email is not unique (i.e. exists already in database)
    ERR_EMAIL_TAKEN = -4
    # Cannot find the email/password pair in the database (i.e. login fail)
    ERR_BAD_CREDENTIALS = -5
    # Generic error for an invalid property
    ERR_INVALID_FIELD = -6
    # Generic error for an unseccessful action
    ERR_UNSUCCESSFUL = -7

    def assertErrCode(self, respData, errCode = SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'err_code' : errCode }
        self.assertDictEqual(expected, respData)


# Examples from Warmup
    def testBadAdd1(self):
        respData = self.makeRequest("/user/add_user", method="POST", data = { 'name' : '', 'email' : 'example@example.com', 'password' : 'nopassword'} )
        self.assertErrCode(respData, ERR_INVALID_NAME)

    def testBadAdd2(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'jim', 'password' : 'a'} )
        respData = self.makeRequest("/users/add", method="POST", data = { 'user' : 'jim', 'password' : 'b'} )
        self.assertResponse(respData, testLib.RestTestCase.ERR_USER_EXISTS)

    def testBadAdd3(self):
        name = 'a' * 150
        respData = self.makeRequest("/users/add", method="POST", data = { 'user' : name, 'password' : 'pw'} )
        self.assertResponse(respData, testLib.RestTestCase.ERR_BAD_USERNAME)

    def testLogin4(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'jon', 'password' : 'pw'} )
        self.makeRequest("/users/login", method="POST", data = { 'user' : 'jon', 'password' : 'pw'} )
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'jon', 'password' : 'pw'} )
        self.assertResponse(respData, count = 3)

    def testLoginBad5(self):
        self.makeRequest("/users/add", method="POST", data = { 'user' : 'jim', 'password' : 'a'} )
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'jon', 'password' : 'cow'} )
        self.assertResponse(respData, None, testLib.RestTestCase.ERR_BAD_CREDENTIALS)

    def testLoginBad6(self):
        respData = self.makeRequest("/users/login", method="POST", data = { 'user' : 'NOTINDB', 'password' : 'cow'} )
        self.assertResponse(respData, None, testLib.RestTestCase.ERR_BAD_CREDENTIALS)








