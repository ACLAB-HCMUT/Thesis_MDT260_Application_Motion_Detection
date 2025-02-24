import express from 'express'
import { userController } from '~/controllers/userController'
import { userValidation } from '~/validations/userValidation'
import IpMiddleware from '~/middlewares/ipMiddleWare'

const profileRouter = express.Router()

profileRouter.get('/', IpMiddleware('get-profile'), userController.getProfile)
profileRouter.put('/edit-profile', IpMiddleware('update-profile'), userController.editProfile)
profileRouter.put('/edit-login', IpMiddleware('update-login'), userController.updateLoginInfo)
profileRouter.put('/edit-emergency-contact', userValidation.updateEmergencyContact, IpMiddleware('update-emergency-contact'), userController.updateEmergencyContact)

export const profileRoute = profileRouter