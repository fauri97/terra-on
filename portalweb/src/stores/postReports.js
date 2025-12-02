// src/stores/postReports.js
import { defineStore } from 'pinia'
import { apiClient } from '@/services/apiClient'

export const usePostReportsStore = defineStore('postReports', {
  state: () => ({
    items: [],
    loading: false,
    error: null,
    updatingIds: [], // ids que estão sendo atualizados
  }),

  getters: {
    totalCount: (state) => state.items.length,
    statusOptions: (state) => {
      const all = state.items.map((i) => i.status).filter(Boolean)
      return [...new Set(all)]
    },
    isUpdating: (state) => (id) => state.updatingIds.includes(id),
  },

  actions: {
    async fetchAll() {
      this.loading = true
      this.error = null

      try {
        const res = await apiClient.get('api/reportposts', {
          auth: true,
        })

        const payload = res.data

        if (payload.statusCode !== 0 && payload.statusCode !== 200) {
          throw new Error(payload.message || 'Erro ao carregar denúncias de posts.')
        }

        this.items = payload.data || []
      } catch (err) {
        console.error(err)
        this.error =
          err?.response?.data?.message ||
          err?.message ||
          'Não foi possível carregar as denúncias de posts.'
      } finally {
        this.loading = false
      }
    },

    async updateStatus(id, newStatus) {
      // evita várias chamadas pro mesmo id
      if (this.updatingIds.includes(id)) return

      this.error = null
      this.updatingIds.push(id)

      const item = this.items.find((i) => i.id === id)
      const oldStatus = item?.status

      const body = {
        newStatus: (newStatus || '').toLowerCase(),
      }

      if (item) {
        item.status = body.newStatus
      }

      try {
        const res = await apiClient.put(`api/reportposts/${id}`, body, {
          auth: true,
        })

        const payload = res.data

        if (payload.statusCode !== 0 && payload.statusCode !== 200) {
          throw new Error(payload.message || 'Erro ao atualizar status da denúncia.')
        }

        const backendStatus = payload?.data?.newStatus
        if (item && backendStatus) {
          item.status = backendStatus
        }
      } catch (err) {
        console.error(err)

        if (item) {
          item.status = oldStatus
        }

        this.error =
          err?.response?.data?.message ||
          err?.message ||
          'Não foi possível atualizar o status da denúncia.'
      } finally {
        this.updatingIds = this.updatingIds.filter((x) => x !== id)
      }
    },
  },
})
