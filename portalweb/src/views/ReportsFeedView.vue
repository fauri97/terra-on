<template>
  <div class="max-w-3xl mx-auto space-y-4">
    <div class="flex items-center justify-between mb-2">
      <div>
        <h2 class="text-2xl font-bold text-base-content">Denúncias recentes</h2>
        <p class="text-sm text-base-content/70">
          Acompanhe as denúncias registradas pela comunidade em tempo real.
        </p>
      </div>

      <button class="btn btn-ghost btn-sm" :disabled="loading" @click="refresh">
        <span class="material-symbols-outlined text-sm">refresh</span>
        Atualizar
      </button>
    </div>

    <div v-if="loading && reports.length === 0" class="w-full flex justify-center py-10">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <div v-else-if="error && reports.length === 0" class="alert alert-error text-sm">
      <span>{{ error }}</span>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="report in reports"
        :key="report.id"
        class="card bg-base-100 shadow-sm border border-base-200"
      >
        <div class="card-body p-4 space-y-3">
          <div class="flex items-start gap-3">
            <div class="avatar">
              <div
                class="w-10 h-10 rounded-full bg-base-200 border border-base-300 overflow-hidden flex items-center justify-center"
              >
                <img
                  v-if="getAvatarSrc(report.authorAvatar)"
                  :src="getAvatarSrc(report.authorAvatar)"
                  :alt="report.authorName"
                  class="w-full h-full object-cover"
                />
                <span v-else class="text-xs font-semibold text-base-content/70">
                  {{ getInitials(report.authorName) }}
                </span>
              </div>
            </div>

            <div class="flex-1">
              <div class="flex items-center justify-between gap-2">
                <div>
                  <p class="font-semibold text-sm leading-tight">
                    {{ report.authorName }}
                  </p>
                  <p class="text-[11px] text-base-content/60">
                    {{ formatAddress(report) }}
                  </p>
                </div>
                <button
                  v-if="hasCoords(report)"
                  type="button"
                  class="btn btn-ghost btn-xs gap-1"
                  @click="goToMap(report)"
                >
                  <span class="material-symbols-outlined text-sm">location_on</span>
                  <span class="hidden sm:inline text-[11px]"> Ver no mapa </span>
                </button>
              </div>
            </div>
          </div>
          <p class="text-sm text-base-content/90 whitespace-pre-line">
            {{ report.description }}
          </p>
          <div v-if="report.images && report.images.length" class="relative">
            <div class="overflow-hidden rounded-xl border border-base-300 bg-base-200">
              <img
                :src="getImageSrc(report.images[currentImageIndex(report.id)])"
                alt="Imagem da denúncia"
                class="w-full max-h-96 object-cover"
              />
            </div>
            <button
              v-if="report.images.length > 1"
              type="button"
              class="btn btn-circle btn-xs absolute left-2 top-1/2 -translate-y-1/2"
              @click="prevImage(report.id, report.images.length)"
            >
              <span class="material-symbols-outlined text-sm">chevron_left</span>
            </button>

            <button
              v-if="report.images.length > 1"
              type="button"
              class="btn btn-circle btn-xs absolute right-2 top-1/2 -translate-y-1/2"
              @click="nextImage(report.id, report.images.length)"
            >
              <span class="material-symbols-outlined text-sm">chevron_right</span>
            </button>
            <div v-if="report.images.length > 1" class="flex justify-center gap-1 mt-1">
              <button
                v-for="(_, idx) in report.images"
                :key="idx"
                type="button"
                class="h-1.5 rounded-full transition-all"
                :class="currentImageIndex(report.id) === idx ? 'w-4 bg-primary' : 'w-2 bg-base-300'"
                @click="setImageIndex(report.id, idx)"
              ></button>
            </div>
          </div>
          <div class="flex items-center justify-between text-xs mt-1">
            <div class="flex items-center gap-3">
              <div class="flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">favorite</span>
                <span>{{ report.likeCount }} curtida(s)</span>
              </div>

              <button
                v-if="report.comments && report.comments.length"
                type="button"
                class="flex items-center gap-1 text-primary"
                @click="toggleComments(report.id)"
              >
                <span class="material-symbols-outlined text-sm"> chat_bubble </span>
                <span>{{ report.comments.length }} comentário(s)</span>
              </button>
            </div>
          </div>
          <div
            v-if="isCommentsOpen(report.id) && report.comments && report.comments.length"
            class="mt-2 border-t border-base-200 pt-2 space-y-2"
          >
            <div
              v-for="comment in report.comments"
              :key="comment.id"
              class="flex items-start gap-2"
            >
              <div class="avatar">
                <div
                  class="w-7 h-7 rounded-full bg-base-200 border border-base-300 overflow-hidden flex items-center justify-center"
                >
                  <img
                    v-if="getAvatarSrc(comment.authorAvatar)"
                    :src="getAvatarSrc(comment.authorAvatar)"
                    :alt="comment.authorName"
                    class="w-full h-full object-cover"
                  />
                  <span v-else class="text-[10px] font-semibold text-base-content/70">
                    {{ getInitials(comment.authorName) }}
                  </span>
                </div>
              </div>

              <div class="bg-base-200 rounded-2xl px-3 py-2 max-w-full">
                <p class="text-[11px] font-semibold mb-0.5">
                  {{ comment.authorName }}
                </p>
                <p class="text-[12px] text-base-content/90 whitespace-pre-line">
                  {{ comment.text }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div
        v-if="!loading && !error && reports.length === 0"
        class="text-center text-sm text-base-content/60 py-8"
      >
        Nenhuma denúncia encontrada.
      </div>

      <div v-if="hasMore && reports.length > 0" class="flex justify-center pt-2">
        <button
          class="btn btn-outline btn-sm"
          :class="{ loading: loadingMore }"
          :disabled="loadingMore"
          @click="loadMore"
        >
          <span v-if="!loadingMore">Carregar mais</span>
          <span v-else>Carregando...</span>
        </button>
      </div>

      <div
        v-else-if="!hasMore && reports.length > 0"
        class="text-center text-[11px] text-base-content/50 pb-4"
      >
        Você chegou ao fim da lista.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { apiClient } from '@/services/apiClient'

const reports = ref([])
const loading = ref(false)
const loadingMore = ref(false)
const error = ref(null)

const page = ref(1)
const pageSize = ref(5)
const hasMore = ref(true)

const imageIndexes = reactive({})

const openComments = reactive({})

const currentImageIndex = (reportId) => {
  return imageIndexes[reportId] ?? 0
}

const setImageIndex = (reportId, index) => {
  imageIndexes[reportId] = index
}

const nextImage = (reportId, total) => {
  const current = currentImageIndex(reportId)
  imageIndexes[reportId] = (current + 1) % total
}

const prevImage = (reportId, total) => {
  const current = currentImageIndex(reportId)
  imageIndexes[reportId] = (current - 1 + total) % total
}

const toggleComments = (reportId) => {
  openComments[reportId] = !openComments[reportId]
}

const isCommentsOpen = (reportId) => {
  return !!openComments[reportId]
}

const getAvatarSrc = (avatar) => {
  if (!avatar || !avatar.base64) return null
  const contentType = avatar.contentType || 'image/png'
  if (avatar.base64.startsWith('data:')) return avatar.base64
  return `data:${contentType};base64,${avatar.base64}`
}

const getImageSrc = (image) => {
  if (!image || !image.base64) return ''
  const contentType = image.contentType || 'image/jpeg'
  if (image.base64.startsWith('data:')) return image.base64
  return `data:${contentType};base64,${image.base64}`
}

const getInitials = (name) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase()
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
}

const formatAddress = (report) => {
  const parts = []

  if (report.address) parts.push(report.address)
  if (report.bairro) parts.push(report.bairro)
  if (report.city) parts.push(report.city)
  if (report.state) parts.push(report.state)

  if (!parts.length) return 'Endereço não informado'
  return parts.join(' · ')
}

const hasCoords = (report) => {
  return (
    report &&
    report.latitude &&
    report.longitude &&
    String(report.latitude).trim() !== '' &&
    String(report.longitude).trim() !== ''
  )
}

const goToMap = (report) => {
  if (!report) return
  if (hasCoords(report)) {
    const lat = String(report.latitude).trim()
    const lng = String(report.longitude).trim()
    const url = `https://www.google.com/maps?q=${encodeURIComponent(`${lat},${lng}`)}`
    window.open(url, '_blank')
    return
  }

  const address = formatAddress(report)
  if (!address || address === 'Endereço não informado') return

  const url = `https://www.google.com/maps?q=${encodeURIComponent(address)}`
  window.open(url, '_blank')
}

const fetchReports = async (opts = { reset: false }) => {
  if (opts.reset) {
    page.value = 1
    hasMore.value = true
    reports.value = []
  }

  if (!hasMore.value) return

  const isFirstPage = page.value === 1 && opts.reset
  if (isFirstPage || reports.value.length === 0) {
    loading.value = true
  } else {
    loadingMore.value = true
  }

  error.value = null

  try {
    const res = await apiClient.get('api/report', {
      auth: true,
      params: {
        page: page.value,
        pageSize: pageSize.value,
      },
    })

    const payload = res.data

    if (payload.statusCode !== 0 && payload.statusCode !== 200) {
      throw new Error(payload.message || 'Erro ao carregar denúncias.')
    }

    const newItems = payload.data || []

    if (newItems.length < pageSize.value) {
      hasMore.value = false
    }

    reports.value = opts.reset ? newItems : [...reports.value, ...newItems]

    for (const r of newItems) {
      if (imageIndexes[r.id] === undefined) {
        imageIndexes[r.id] = 0
      }
    }
  } catch (err) {
    console.error(err)
    error.value =
      err?.response?.data?.message || err?.message || 'Não foi possível carregar as denúncias.'
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

const refresh = async () => {
  await fetchReports({ reset: true })
}

const loadMore = async () => {
  if (!hasMore.value || loadingMore.value) return
  page.value += 1
  await fetchReports({ reset: false })
}

onMounted(() => {
  fetchReports({ reset: true })
})
</script>
