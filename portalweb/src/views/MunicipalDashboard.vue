<template>
  <div class="space-y-6">
    <!-- Cabeçalho -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
      <div>
        <h2 class="text-2xl font-bold text-base-content">
          Dashboard municipal
        </h2>
        <p class="text-sm text-base-content/70">
          Visão geral das denúncias em
          <span class="font-semibold">
            {{ cityLabel || '—' }}
          </span>
        </p>
      </div>

      <div class="flex items-center gap-2">
        <div class="flex items-center gap-2">
          <input
            v-model="city"
            type="text"
            class="input input-sm input-bordered w-40"
            placeholder="Cidade"
          />
          <button
            class="btn btn-sm btn-outline"
            :disabled="loading || !city"
            @click="reloadWithCity"
          >
            <span class="material-symbols-outlined text-sm">search</span>
            Filtrar
          </button>
        </div>

        <button
          class="btn btn-ghost btn-sm"
          :disabled="loading"
          @click="loadDashboard"
        >
          <span class="material-symbols-outlined text-sm">refresh</span>
          Atualizar
        </button>
      </div>
    </div>

    <!-- Estados globais -->
    <div v-if="loading && !dashboard" class="w-full flex justify-center py-10">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <div v-else-if="error && !dashboard" class="alert alert-error shadow-lg">
      <span>{{ error }}</span>
    </div>

    <template v-else-if="dashboard">
      <!-- Cards principais -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Total denúncias -->
        <div class="card bg-base-100 shadow-sm border border-base-200">
          <div class="card-body py-4 px-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-xs uppercase tracking-wide text-base-content/60">
                  Total de denúncias
                </p>
                <p class="text-2xl font-bold text-base-content">
                  {{ dashboard.totalPosts }}
                </p>
              </div>
              <span class="material-symbols-outlined text-3xl text-primary">
                summarize
              </span>
            </div>
          </div>
        </div>

        <!-- Hoje -->
        <div class="card bg-base-100 shadow-sm border border-base-200">
          <div class="card-body py-4 px-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-xs uppercase tracking-wide text-base-content/60">
                  Hoje
                </p>
                <p class="text-2xl font-bold text-base-content">
                  {{ dashboard.totalPostsToday }}
                </p>
                <p class="text-xs text-base-content/60">
                  Denúncias registradas hoje
                </p>
              </div>
              <span class="material-symbols-outlined text-3xl text-secondary">
                today
              </span>
            </div>
          </div>
        </div>

        <!-- Comentários -->
        <div class="card bg-base-100 shadow-sm border border-base-200">
          <div class="card-body py-4 px-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-xs uppercase tracking-wide text-base-content/60">
                  Comentários
                </p>
                <p class="text-2xl font-bold text-base-content">
                  {{ dashboard.totalComments }}
                </p>
                <p class="text-xs text-base-content/60">
                  Interações nas denúncias
                </p>
              </div>
              <span class="material-symbols-outlined text-3xl text-accent">
                chat_bubble
              </span>
            </div>
          </div>
        </div>
      </section>

      <!-- Status -->
      <section>
        <h3 class="text-sm font-semibold text-base-content/80 mb-2">
          Situação das denúncias
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          <!-- Aqui você pode trocar por um componente StatusCard se já existir -->
          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Pendentes
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.pending }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-warning">
                  hourglass_top
                </span>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Em andamento
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.inProgress }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-info">
                  sync
                </span>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Resolvidas
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.resolved }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-success">
                  check_circle
                </span>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Arquivadas
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.dismissed }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-base-content/50">
                  archive
                </span>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Inapropriadas
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.inappropriate }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-error">
                  report
                </span>
              </div>
            </div>
          </div>

          <div class="card bg-base-100 shadow-sm border border-base-200">
            <div class="card-body py-3 px-3">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-[11px] uppercase tracking-wide text-base-content/60">
                    Desativadas
                  </p>
                  <p class="text-lg font-bold text-base-content">
                    {{ dashboard.diactivated }}
                  </p>
                </div>
                <span class="material-symbols-outlined text-xl text-base-content/50">
                  visibility_off
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Gráfico últimos 30 dias + bairros -->
      <section class="grid grid-cols-1 lg:grid-cols-3 gap-4 items-start">
        <!-- Evolução por dia (GRÁFICO) -->
        <div class="card bg-base-100 shadow-sm border border-base-200 lg:col-span-2">
          <div class="card-body">
            <div class="flex items-center justify-between mb-2">
              <div>
                <h3 class="card-title text-sm">
                  Evolução nos últimos 30 dias
                </h3>
                <p class="text-xs text-base-content/60">
                  Total no período: {{ totalLast30Days }}
                </p>
              </div>
            </div>

            <div v-if="dashboard.reportsPerDay?.length" class="mt-4">
              <div class="w-full h-48">
                <svg
                  :viewBox="`0 0 ${chartWidth} ${chartHeight}`"
                  class="w-full h-full"
                  preserveAspectRatio="none"
                >
                  <!-- grade horizontal leve -->
                  <g
                    v-for="(lineY, idx) in gridLinesY"
                    :key="idx"
                    :transform="`translate(0, ${lineY})`"
                  >
                    <line
                      x1="0"
                      :y1="0"
                      :x2="chartWidth"
                      :y2="0"
                      class="stroke-base-300"
                      stroke-width="0.5"
                    />
                  </g>

                  <!-- área sob a linha -->
                  <path
                    v-if="chartAreaPath"
                    :d="chartAreaPath"
                    class="fill-primary/15"
                  />

                  <!-- linha principal -->
                  <polyline
                    v-if="chartLinePoints"
                    :points="chartLinePoints"
                    class="stroke-primary"
                    fill="none"
                    stroke-width="2"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  />

                  <!-- marcadores -->
                  <g v-for="(p, idx) in chartPoints" :key="idx">
                    <circle
                      v-if="p.count > 0"
                      :cx="p.x"
                      :cy="p.y"
                      r="2.5"
                      class="fill-primary stroke-base-100"
                      stroke-width="1"
                    />
                  </g>
                </svg>
              </div>

              <div class="mt-2 flex justify-between text-[10px] text-base-content/60">
                <span>
                  {{ formatShortDate(dashboard.reportsPerDay[0]?.date) }}
                </span>
                <span>
                  {{
                    formatShortDate(
                      dashboard.reportsPerDay[dashboard.reportsPerDay.length - 1]?.date,
                    )
                  }}
                </span>
              </div>
            </div>

            <p v-else class="text-sm text-base-content/60 mt-2">
              Ainda não há dados suficientes para o período.
            </p>
          </div>
        </div>

        <!-- Bairros -->
        <div class="card bg-base-100 shadow-sm border border-base-200">
          <div class="card-body">
            <h3 class="card-title text-sm mb-1">
              Bairros com mais denúncias
            </h3>
            <p class="text-xs text-base-content/60 mb-2">
              Ranking dos pontos mais críticos do município.
            </p>

            <div v-if="sortedNeighborhoods.length" class="space-y-2 mt-2">
              <div
                v-for="(n, idx) in sortedNeighborhoods"
                :key="n.neighborhood + idx"
                class="flex items-center gap-2"
              >
                <div
                  class="w-7 h-7 rounded-full bg-primary/10 flex items-center justify-center text-[11px] font-semibold text-primary"
                >
                  {{ idx + 1 }}
                </div>
                <div class="flex-1">
                  <div class="flex items-center justify-between text-sm">
                    <span class="font-medium">
                      {{ n.neighborhood || 'Não informado' }}
                    </span>
                    <span class="text-xs text-base-content/70">
                      {{ n.reportCount }} denúnc{{ n.reportCount === 1 ? 'ia' : 'ias' }}
                    </span>
                  </div>
                  <div class="w-full h-1.5 bg-base-200 rounded-full mt-1 overflow-hidden">
                    <div
                      class="h-full bg-primary rounded-full"
                      :style="{ width: neighborhoodPercent(n) }"
                    ></div>
                  </div>
                </div>
              </div>
            </div>
            <p v-else class="text-sm text-base-content/60 mt-2">
              Ainda não há dados por bairro para esta cidade.
            </p>
          </div>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { apiClient } from '@/services/apiClient'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const initialCityFromQuery = route.query.city
  ? String(route.query.city)
  : ''

const city = ref(initialCityFromQuery || authStore.userCity || '')

const dashboard = ref(null)
const loading = ref(false)
const error = ref('')

const cityLabel = computed(() =>
  (dashboard.value?.city || city.value || '').trim(),
)

// --- números gerais últimos 30 dias ---
const totalLast30Days = computed(() => {
  const arr = dashboard.value?.reportsPerDay || []
  return arr.reduce((sum, d) => sum + (d.reportCount || 0), 0)
})

const maxReportsPerDay = computed(() => {
  const arr = dashboard.value?.reportsPerDay || []
  if (!arr.length) return 1
  const max = Math.max(...arr.map((d) => d.reportCount || 0))
  return max || 1
})

// --- bairros ---
const sortedNeighborhoods = computed(() => {
  const arr = dashboard.value?.reportsPerNeighborhood || []
  return [...arr].sort((a, b) => (b.reportCount || 0) - (a.reportCount || 0))
})

function neighborhoodPercent(n) {
  const arr = dashboard.value?.reportsPerNeighborhood || []
  const max = arr.length
    ? Math.max(...arr.map((x) => x.reportCount || 0))
    : 1
  const pct = ((n.reportCount || 0) / max) * 100
  return `${pct || 0}%`
}

// --- gráfico SVG (linha) ---
const chartWidth = 300
const chartHeight = 100
const chartPadding = 8

const chartPoints = computed(() => {
  const arr = dashboard.value?.reportsPerDay || []
  if (!arr.length) return []

  const max = maxReportsPerDay.value || 1
  const usableWidth = chartWidth - chartPadding * 2
  const usableHeight = chartHeight - chartPadding * 2
  const stepX = arr.length > 1 ? usableWidth / (arr.length - 1) : 0

  return arr.map((d, idx) => {
    const count = d.reportCount || 0
    const x = chartPadding + idx * stepX
    const y =
      chartHeight - chartPadding - (count / max) * usableHeight
    return { x, y, count }
  })
})

const chartLinePoints = computed(() => {
  if (!chartPoints.value.length) return ''
  return chartPoints.value
    .map((p) => `${p.x},${p.y}`)
    .join(' ')
})

// área preenchida sob a linha
const chartAreaPath = computed(() => {
  const pts = chartPoints.value
  if (!pts.length) return ''

  const first = pts[0]
  const last = pts[pts.length - 1]

  const baseY = chartHeight - chartPadding

  const line = pts.map((p) => `L ${p.x} ${p.y}`).join(' ')

  // começa na base do primeiro ponto, sobe, segue a linha,
  // desce na base do último e fecha
  return `M ${first.x} ${baseY} ${line} L ${last.x} ${baseY} Z`
})

// linhas de grade horizontais (3 linhas além da base)
const gridLinesY = computed(() => {
  const lines = []
  const baseY = chartHeight - chartPadding
  const topY = chartPadding
  const step = (baseY - topY) / 3

  for (let i = 0; i <= 3; i++) {
    lines.push(topY + step * i)
  }
  return lines
})

function formatShortDate(value) {
  if (!value) return ''
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return ''
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  return `${day}/${month}`
}

async function loadDashboard() {
  if (!city.value) {
    error.value = 'Informe uma cidade para visualizar a dashboard.'
    return
  }

  loading.value = true
  error.value = ''

  try {
    const resp = await apiClient.get('/api/admin/dashboard/municipal', {
      params: { city: city.value },
    })

    const body = resp.data || {}
    const statusCode =
      typeof body.statusCode === 'number' ? body.statusCode : 0

    if (![0, 200].includes(statusCode)) {
      throw new Error(body.message || 'Erro ao carregar dashboard municipal.')
    }

    dashboard.value = body.data || null
  } catch (err) {
    console.error(err)
    error.value =
      err?.message || 'Erro ao carregar dashboard. Tente novamente mais tarde.'
  } finally {
    loading.value = false
  }
}

function reloadWithCity() {
  router.replace({
    name: 'gov-dashboard',
    query: city.value ? { city: city.value } : undefined,
  })
  loadDashboard()
}

onMounted(() => {
  loadDashboard()
})
</script>
