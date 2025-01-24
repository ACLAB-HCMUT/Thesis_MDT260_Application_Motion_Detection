import { StatusCodes } from 'http-status-codes'
import { userService } from '~/services/userService'

const createNew = async (req, res, next) => {
  try {
    const createdUser = await userService.createNew(req.body)

    res.status(StatusCodes.OK).json(createdUser)
  } catch (error) {
    next(error)
  }
}

export const userController = {
  createNew
}
