// src/schemas/userSchema.ts
import { z } from 'zod'

// Optional string with min length, reused
const optionalNonEmptyString = z.string().min(1, 'Field cannot be empty.').optional()

export const userProfileSchema = z.object({
  uid: z.string().min(1, 'Firebase UID cannot be empty.'),
  email: z
  .string()
  .min(1, 'Email is required.')
  .email('Must be a valid email address.'),

  name: z.string().min(1, 'Name cannot be empty.'),

  photoURL: z.string().url('Photo URL must be a valid URL.'),

  bio: optionalNonEmptyString,
  location: optionalNonEmptyString,

  interests: z
    .array(z.string().min(1, 'Interest cannot be empty.'))
    .default([]),

  deviceToken: optionalNonEmptyString,
})

// Infer TypeScript type
export type UserProfileInput = z.infer<typeof userProfileSchema>
