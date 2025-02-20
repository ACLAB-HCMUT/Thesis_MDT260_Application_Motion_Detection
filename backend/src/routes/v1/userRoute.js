import express from 'express'
import { userValidation } from '~/validations/userValidation'
import { userController } from '~/controllers/userController'
import parseEmailOrUsername from '~/middlewares/emailOrUsername'
import validateToken from '~/middlewares/validateToken'
import { profileRoute } from '~/routes/v1/profileRoute'

const userRouter = express.Router()

userRouter.post('/login', userValidation.login, parseEmailOrUsername, userController.login)
userRouter.post('/register', userValidation.createNew, userController.createNew)
userRouter.use('/profile', validateToken, profileRoute)

export const userRoute = userRouter
