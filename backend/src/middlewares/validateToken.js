import JWT from 'jsonwebtoken'
import { env } from '~/config/environment'
import { StatusCodes } from 'http-status-codes'
import ApiError from '~/utils/ApiError'

const accessTokenSecret = env.ACCESSTOKEN_SECRET

const validateToken = (req, res, next) => {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]

  if (token == null) {
    return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Token not provided'))
  }

  JWT.verify(token, accessTokenSecret, (err, user) => {
    if (err) {
      return next(new ApiError(StatusCodes.FORBIDDEN, 'Forbidden'))
    }
    req.user = user
    next()
  })
}

export default validateToken