import express from 'express'
import { userValidation } from '~/validations/userValidation'
import { userController } from '~/controllers/userController'
import parseEmailOrUsername from '~/middlewares/emailOrUsername'

const Router = express.Router()

// Router.route('/')
//   .get((req, res) => {
//     res.status(StatusCodes.OK).json({ message: 'GET messages!' })
//   })
//   .post(userValidation.createNew, userController.createNew)


Router.get('/:email', userController.findOneByEmail)
Router.post('/login', userValidation.login, parseEmailOrUsername, userController.login)
Router.post('/register', userValidation.createNew, userController.createNew)

export const userRoute = Router
