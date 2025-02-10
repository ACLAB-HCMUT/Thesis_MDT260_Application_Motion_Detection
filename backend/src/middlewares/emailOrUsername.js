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
    req.body.email = email
    return next()
  }

  if (!emailOrUsername) {
    return next(new ApiError(StatusCodes.BAD_REQUEST, 'Username and password are required'))
  }

  if (isEmail(emailOrUsername)) {
    req.body.email = emailOrUsername
  } else {
    const username = emailOrUsername
    const user = await userController.findOneByUsername(username, next)
    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }
    req.body.email = user.email
  }
  return next()
}

export default parseEmailOrUsername
