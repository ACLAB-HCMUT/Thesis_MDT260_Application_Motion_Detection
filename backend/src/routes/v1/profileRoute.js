import express from 'express'
import { userController } from '~/controllers/userController'
import IpMiddleware from '~/middlewares/ipMiddleWare'

const profileRouter = express.Router()

profileRouter.get('/', IpMiddleware('get-profile'), userController.getProfile)
profileRouter.put('/edit', IpMiddleware('update-profile'), userController.editProfile)

export const profileRoute = profileRouter