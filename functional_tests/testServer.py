import unittest
import os
import testLib

class TestUser(testLib.RestTestCase):

    SUCCESS = 1
    ERR_INVALID_NAME = -1
    ERR_INVALID_TIME = -10
    ERR_INVALID_FIELD = -6
    ERR_UNSUCCESSFUL = -7
    ERR_INVALID_EMAIL = -2
    ERR_INVALID_PASSWORD = -3
    ERR_EMAIL_TAKEN = -4
    ERR_BAD_CREDENTIALS = -5
    ERR_INVALID_SESSION = -11
    ERR_INVALID_PERMISSIONS = -12

    def assertErrCode(self, respData, errCode = SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'err_code' : errCode }
        self.assertDictEqual(expected, respData)

    def testBadAdd(self):
        respData = self.makeRequest("/user/add_user", method="POST", data = { 'name' : 'Foo', 'email' : 'gtl', 'password' : 'nopassword'} )
        self.assertErrCode(respData, ERR_INVALID_EMAIL)

    def testGoodAdd(self):
        respData = self.makeRequest("/user/add_user", method="POST", data = { 'name' : 'Foo', 'email' : 'ftest@example.com', 'password' : 'nopassword'} )
        self.assertErrCode(respData, SUCCESS)

    def testBadLogin(self):
        respData = self.makeRequest("/user/login_user", method="POST", data = { 'email' : 'gtl', 'password' : 'nopassword'} )
        self.assertErrCode(respData, ERR_BAD_CREDENTIALS)

    def testGoodLogin(self):
        self.makeRequest("/user/add_user", method="POST", data = { 'name' : 'Foo', 'email' : 'ftest@example.com', 'password' : 'nopassword'} )
        respData = self.makeRequest("/user/login_user", method="POST", data = { 'email' : 'ftest@example.com', 'password' : 'nopassword'} )
        self.assertErrCode(respData, SUCCESS)











