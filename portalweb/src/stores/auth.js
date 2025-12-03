import { defineStore } from 'pinia'
import { setAuthToken, clearAuthToken } from '@/services/apiClient'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    userAvatar: (state) => state.user?.avatarBase64 || null,
    userRole: (state) => state.user?.role || 'User',
    userCity: (state) => state.user?.userCity || '',

    userAvatarSrc: (state) => {
      const b64 = state.user?.avatarBase64
      if (!b64) return null
      if (b64.startsWith('data:')) return b64
      return `data:image/png;base64,${b64}`
    },
  },

  actions: {
    initFromStorage() {
      const raw = localStorage.getItem('terraon_user')
      if (!raw) return

      try {
        const user = JSON.parse(raw)
        this.user = user
        if (user?.accessToken) {
          setAuthToken(user.accessToken)
        }
      } catch {
        localStorage.removeItem('terraon_user')
      }
    },

    setUser(user) {
      this.user = user
      if (user?.accessToken) {
        setAuthToken(user.accessToken)
      }
      localStorage.setItem('terraon_user', JSON.stringify(user))
    },

    logout() {
      this.user = null
      clearAuthToken()
      localStorage.removeItem('terraon_user')
    },
  },
})
