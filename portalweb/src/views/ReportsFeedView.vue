<template>
  <div class="max-w-3xl mx-auto space-y-4">
    <!-- Cabeçalho + Filtros -->
    <div class="space-y-3">
      <!-- Cabeçalho -->
      <div class="flex items-center justify-between gap-2">
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

      <!-- Filtros em card -->
      <div class="card bg-base-100/90 border border-base-300 shadow-sm">
        <div class="card-body py-3 px-3 md:px-4 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <!-- Infos / badges -->
          <div class="flex flex-wrap items-center gap-2 text-[11px] md:text-xs">
            <div class="flex items-center gap-1">
              <span class="material-symbols-outlined text-sm text-base-content/70">
                list_alt
              </span>
              <span class="badge badge-outline">
                Total: {{ reports.length }}
              </span>
            </div>

            <div v-if="filteredReports.length !== reports.length" class="flex items-center gap-1">
              <span class="material-symbols-outlined text-sm text-primary">
                filter_alt
              </span>
              <span class="badge badge-outline badge-primary">
                Filtrados: {{ filteredReports.length }}
              </span>
            </div>
          </div>

          <!-- Controles de filtro -->
          <div class="flex flex-col sm:flex-row gap-2 w-full md:w-auto">
            <!-- Filtro de status -->
            <div class="join w-full sm:w-48">
              <span class="join-item btn btn-ghost btn-xs px-2 gap-1 text-[11px] text-base-content/80">
                <span class="material-symbols-outlined text-sm">flag</span>
                <span class="hidden sm:inline">Status</span>
              </span>
              <select v-model="statusFilter" class="join-item select select-bordered select-xs w-full">
                <option value="">Todos</option>
                <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </div>

            <!-- Busca de texto -->
            <div class="join w-full sm:w-64">
              <span class="join-item btn btn-ghost btn-xs px-2 gap-1 text-[11px] text-base-content/80">
                <span class="material-symbols-outlined text-sm">search</span>
                <span class="hidden sm:inline">Buscar</span>
              </span>
              <input v-model="search" type="text" placeholder="Descrição, autor ou endereço"
                class="join-item input input-bordered input-xs w-full" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estados globais -->
    <div v-if="loading && reports.length === 0" class="w-full flex justify-center py-10">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <div v-else-if="error && reports.length === 0" class="alert alert-error text-sm">
      <span>{{ error }}</span>
    </div>

    <div v-else class="space-y-4">
      <div v-for="report in filteredReports" :key="report.id" class="card bg-base-100 shadow-sm border border-base-200">
        <div class="card-body p-4 space-y-3">
          <!-- Cabeçalho / autor -->
          <div class="flex items-start gap-3">
            <div class="avatar">
              <div
                class="w-10 h-10 rounded-full bg-base-200 border border-base-300 overflow-hidden flex items-center justify-center">
                <img v-if="getAvatarSrc(report.authorAvatar)" :src="getAvatarSrc(report.authorAvatar)"
                  :alt="report.authorName" class="w-full h-full object-cover" />
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
                <button v-if="hasCoords(report)" type="button" class="btn btn-ghost btn-xs gap-1"
                  @click="goToMap(report)">
                  <span class="material-symbols-outlined text-sm">location_on</span>
                  <span class="hidden sm:inline text-[11px]"> Ver no mapa </span>
                </button>
              </div>
            </div>
          </div>

          <!-- Descrição -->
          <p class="text-sm text-base-content/90 whitespace-pre-line">
            {{ report.description }}
          </p>

          <!-- Imagens -->
          <div v-if="report.images && report.images.length" class="relative">
            <div class="overflow-hidden rounded-xl border border-base-300 bg-base-200">
              <img :src="getImageSrc(report.images[currentImageIndex(report.id)])" alt="Imagem da denúncia"
                class="w-full max-h-96 object-cover" />
            </div>

            <button v-if="report.images.length > 1" type="button"
              class="btn btn-circle btn-xs absolute left-2 top-1/2 -translate-y-1/2"
              @click="prevImage(report.id, report.images.length)">
              <span class="material-symbols-outlined text-sm">chevron_left</span>
            </button>

            <button v-if="report.images.length > 1" type="button"
              class="btn btn-circle btn-xs absolute right-2 top-1/2 -translate-y-1/2"
              @click="nextImage(report.id, report.images.length)">
              <span class="material-symbols-outlined text-sm">chevron_right</span>
            </button>

            <div v-if="report.images.length > 1" class="flex justify-center gap-1 mt-1">
              <button v-for="(_, idx) in report.images" :key="idx" type="button"
                class="h-1.5 rounded-full transition-all"
                :class="currentImageIndex(report.id) === idx ? 'w-4 bg-primary' : 'w-2 bg-base-300'"
                @click="setImageIndex(report.id, idx)"></button>
            </div>
          </div>

          <!-- Likes / comentários -->
          <div class="flex items-center justify-between text-xs mt-1">
            <div class="flex items-center gap-3">
              <div class="flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">favorite</span>
                <span>{{ report.likeCount }} curtida(s)</span>
              </div>

              <button v-if="report.comments && report.comments.length" type="button"
                class="flex items-center gap-1 text-primary" @click="toggleComments(report.id)">
                <span class="material-symbols-outlined text-sm"> chat_bubble </span>
                <span>{{ report.comments.length }} comentário(s)</span>
              </button>
            </div>
          </div>

          <!-- Lista de comentários -->
          <div v-if="isCommentsOpen(report.id) && report.comments && report.comments.length"
            class="mt-2 border-t border-base-200 pt-2 space-y-2">
            <div v-for="comment in report.comments" :key="comment.id" class="flex items-start gap-2">
              <div class="avatar">
                <div
                  class="w-7 h-7 rounded-full bg-base-200 border border-base-300 overflow-hidden flex items-center justify-center">
                  <img v-if="getAvatarSrc(comment.authorAvatar)" :src="getAvatarSrc(comment.authorAvatar)"
                    :alt="comment.authorName" class="w-full h-full object-cover" />
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

          <!-- STATUS + BOTÃO LADO INFERIOR DIREITO -->
          <div class="flex items-center justify-between mt-3 text-[11px]">
            <div class="flex items-center gap-2">
              <span class="text-base-content/60">Status:</span>
              <span class="badge badge-xs" :class="statusBadgeClass(report.status)">
                {{ formatStatus(report.status) }}
              </span>
            </div>

            <div class="flex items-center gap-2">
              <span v-if="isUpdating(report.id)" class="text-base-content/50 flex items-center gap-1">
                <span class="loading loading-spinner loading-xs"></span>
                Atualizando...
              </span>

              <div class="dropdown dropdown-end">
                <label tabindex="0" class="btn btn-ghost btn-xs gap-1"
                  :class="{ 'btn-disabled': isUpdating(report.id) }">
                  <span class="material-symbols-outlined text-sm">flag</span>
                  <span class="hidden sm:inline">Atualizar status</span>
                </label>
                <ul tabindex="0" class="dropdown-content menu menu-xs p-2 shadow bg-base-100 rounded-box w-44 z-10">
                  <li v-for="opt in statusOptions" :key="opt.value">
                    <button type="button" class="flex justify-between items-center"
                      @click="changeStatus(report, opt.value)">
                      <span>{{ opt.label }}</span>
                      <span v-if="report.status?.toLowerCase() === opt.value"
                        class="material-symbols-outlined text-[13px] text-primary">
                        check
                      </span>
                    </button>
                  </li>
                </ul>
              </div>
            </div>
          </div>
          <!-- FIM STATUS -->
        </div>
      </div>

      <!-- Nada encontrado -->
      <div v-if="!loading && !error && filteredReports.length === 0 && reports.length > 0"
        class="text-center text-sm text-base-content/60 py-8">
        Nenhuma denúncia encontrada para os filtros atuais.
      </div>

      <div v-else-if="!loading && !error && reports.length === 0" class="text-center text-sm text-base-content/60 py-8">
        Nenhuma denúncia encontrada.
      </div>

      <!-- Paginação -->
      <div v-if="hasMore && reports.length > 0" class="flex justify-center pt-2">
        <button class="btn btn-outline btn-sm" :class="{ loading: loadingMore }" :disabled="loadingMore"
          @click="loadMore">
          <span v-if="!loadingMore">Carregar mais</span>
          <span v-else>Carregando...</span>
        </button>
      </div>

      <div v-else-if="!hasMore && reports.length > 0" class="text-center text-[11px] text-base-content/50 pb-4">
        Você chegou ao fim da lista.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
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

const updatingStatus = reactive({})

const search = ref('')
const statusFilter = ref('')

const statusOptions = [
  { value: 'pending', valueNorm: 'pending', label: 'Pendente' },
  { value: 'inprogress', valueNorm: 'inprogress', label: 'Em andamento' },
  { value: 'resolved', valueNorm: 'resolved', label: 'Resolvido' },
  { value: 'inappropriate', valueNorm: 'inappropriate', label: 'Inapropriado' },
  { value: 'dismissed', valueNorm: 'dismissed', label: 'Descartado' },
  { value: 'diactivated', valueNorm: 'diactivated', label: 'Desativado' },
]

const normalizeStatus = (status) => (status ? status.toString().toLowerCase() : '')

const isUpdating = (reportId) => !!updatingStatus[reportId]

const formatStatus = (status) => {
  if (!status) return 'Sem status'
  const s = normalizeStatus(status)
  switch (s) {
    case 'pending':
      return 'Pendente'
    case 'inprogress':
      return 'Em andamento'
    case 'resolved':
      return 'Resolvido'
    case 'inappropriate':
      return 'Inapropriado'
    case 'dismissed':
      return 'Descartado'
    case 'diactivated':
      return 'Desativado'
    default:
      return status
  }
}

const statusBadgeClass = (status) => {
  if (!status) return 'badge-ghost'
  const s = normalizeStatus(status)
  if (s === 'pending') return 'badge-warning'
  if (s === 'inprogress') return 'badge-info'
  if (s === 'resolved') return 'badge-success'
  if (s === 'inappropriate' || s === 'dismissed' || s === 'diactivated') return 'badge-error'
  return 'badge-ghost'
}

const filteredReports = computed(() => {
  let list = reports.value || []

  if (statusFilter.value) {
    const target = statusFilter.value.toLowerCase()
    list = list.filter((r) => normalizeStatus(r.status) === target)
  }

  if (search.value.trim()) {
    const term = search.value.toLowerCase().trim()
    list = list.filter((r) => {
      const fields = [
        r.description,
        r.authorName,
        formatAddress(r),
        formatStatus(r.status),
      ]
        .filter(Boolean)
        .map((x) => x.toString().toLowerCase())

      return fields.some((f) => f.includes(term))
    })
  }

  return list
})

const changeStatus = async (report, newStatus) => {
  if (!report || !report.id) return
  if (isUpdating(report.id)) return

  updatingStatus[report.id] = true
  error.value = null

  const oldStatus = report.status
  report.status = newStatus

  try {
    await apiClient.put(`api/report/${report.id}/status`, { newStatus }, { auth: true })
  } catch (err) {
    console.error(err)
    report.status = oldStatus
    error.value =
      err?.response?.data?.message ||
      err?.message ||
      'Não foi possível atualizar o status da denúncia.'
  } finally {
    updatingStatus[report.id] = false
  }
}

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
