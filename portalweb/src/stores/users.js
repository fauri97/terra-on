import { defineStore } from 'pinia'
import { apiClient } from '@/services/apiClient'

export const useUsersStore = defineStore('users', {
  state: () => ({
    items: [],
    loading: false,
    error: null,
    saving: false,
    toggling: {},
  }),

  getters: {
    activeCount: (state) => state.items.filter((u) => !u.isDeactivated).length,
    inactiveCount: (state) => state.items.filter((u) => u.isDeactivated).length,
  },

  actions: {
    async fetchAll() {
      this.loading = true
      this.error = null

      try {
        const res = await apiClient.get('api/user', { auth: true })
        const payload = res.data

        if (payload.statusCode !== 0 && payload.statusCode !== 200) {
          throw new Error(payload.message || 'Erro ao carregar usuários.')
        }
        this.items = (payload.data || []).map((u) => ({
          ...u,
          isDeactivated: !!u.isDeactivated,
        }))
      } catch (err) {
        console.error(err)
        this.error =
          err?.response?.data?.message ||
          err?.message ||
          'Não foi possível carregar a lista de usuários.'
      } finally {
        this.loading = false
      }
    },

    async updateUser(id, data) {
      this.saving = true

      try {
        const res = await apiClient.put(`api/user/${id}`, data, { auth: true })
        const payload = res.data

        if (payload.statusCode !== 0 && payload.statusCode !== 200) {
          throw new Error(payload.message || 'Erro ao atualizar usuário.')
        }

        const updated = payload.data

        if (updated) {
          this.items = this.items.map((u) => (u.id === id ? { ...u, ...updated } : u))
        } else {
          this.items = this.items.map((u) =>
            u.id === id
              ? {
                  ...u,
                  name: data.name,
                  phoneNumber: data.phoneNumber,
                  city: data.city,
                  state: data.state,
                  base64ProfileImage: data.base64ProfileImage,
                  role: data.role,
                }
              : u,
          )
        }
      } catch (err) {
        console.error(err)
        throw err
      } finally {
        this.saving = false
      }
    },

    async setActive(id) {
      this.toggling = { ...this.toggling, [id]: true }

      try {
        const url = `api/user/activity/${id}`
        await apiClient.put(url, null, { auth: true })
        await this.fetchAll()
      } catch (err) {
        console.error(err)
        throw err
      } finally {
        const clone = { ...this.toggling }
        delete clone[id]
        this.toggling = clone
      }
    },
  },
})
