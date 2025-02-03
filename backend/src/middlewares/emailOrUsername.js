import { StatusCodes } from 'http-status-codes'
import { userController } from '~/controllers/userController'
import ApiError from '~/utils/ApiError'

const isEmail = (str) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(str)
}

const parseEmailOrUsername = async (req, res, next) => {
  const { emailOrUsername, email } = req.body

  if (email) {
    console.log('email', email)
    req.body.email = email
    return next()
  }

  if (!emailOrUsername) {
    console.log('username and password are required')
    return next(new ApiError(StatusCodes.BAD_REQUEST, 'Username and password are required'))
  }

  if (isEmail(emailOrUsername)) {
    req.body.email = emailOrUsername
  } else {
    const username = emailOrUsername
    const user = await userController.findOneByUsername(username)
    if (!user) {
      console.log('Invalid email or password from middleware')
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Invalid email or password from middleware'))
    }
    req.body.email = user.email
  }
  return next()
}

export default parseEmailOrUsername
