<template>
  <div class="space-y-6">
    <!-- Cabeçalho -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
      <div>
        <h2 class="text-2xl font-bold text-base-content">Visão geral do TerraON</h2>
        <p class="text-sm text-base-content/70">
          Panorama geral de usuários, denúncias e cidades com registros na plataforma.
        </p>
      </div>

      <button class="btn btn-ghost btn-sm gap-2" :disabled="loading" @click="loadDashboard">
        <span class="material-symbols-outlined text-base">refresh</span>
        Atualizar
      </button>
    </div>

    <!-- Loading / Erro -->
    <div v-if="loading" class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      <div v-for="n in 4" :key="n" class="stat bg-base-100 shadow-sm rounded-2xl">
        <div class="stat-title">
          <span class="skeleton h-3 w-24"></span>
        </div>
        <div class="stat-value">
          <span class="skeleton h-7 w-20"></span>
        </div>
        <div class="stat-desc">
          <span class="skeleton h-3 w-28"></span>
        </div>
      </div>
    </div>

    <div v-else-if="error" class="alert alert-error">
      <span>{{ error }}</span>
    </div>

    <template v-else>
      <!-- Stats principais -->
      <section class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <div class="stat bg-base-100 shadow-sm rounded-2xl">
          <div class="stat-title">Usuários totais</div>
          <div class="stat-value text-primary">
            {{ formatNumber(dashboard.totalUsers) }}
          </div>
          <div class="stat-desc">
            {{ formatNumber(dashboard.activeUsers) }} ativos ·
            {{ formatNumber(dashboard.inactiveUsers) }} inativos
          </div>
        </div>

        <div class="stat bg-base-100 shadow-sm rounded-2xl">
          <div class="stat-title">Denúncias</div>
          <div class="stat-value text-secondary">
            {{ formatNumber(dashboard.totalPosts) }}
          </div>
          <div class="stat-desc">Hoje: {{ formatNumber(dashboard.totalPostsToday) }}</div>
        </div>

        <div class="stat bg-base-100 shadow-sm rounded-2xl">
          <div class="stat-title">Comentários</div>
          <div class="stat-value text-accent">
            {{ formatNumber(dashboard.totalComments) }}
          </div>
          <div class="stat-desc">Interações em denúncias</div>
        </div>

        <div class="stat bg-base-100 shadow-sm rounded-2xl">
          <div class="stat-title">Cidades com denúncias</div>
          <div class="stat-value text-info">
            {{ formatNumber(dashboard.totalReportCities) }}
          </div>
          <div class="stat-desc">
            Mais ativa: <span class="font-semibold">{{ dashboard.mostActiveCity || '-' }}</span>
          </div>
        </div>
      </section>

      <!-- Linha: atividade x cidades -->
      <section class="grid gap-6 lg:grid-cols-5">
        <!-- Atividade por dia -->
        <div class="lg:col-span-3 space-y-3 bg-base-100 rounded-2xl shadow-sm p-4">
          <div class="flex items-center justify-between gap-2">
            <div>
              <h3 class="font-semibold text-base-content">Atividade recente</h3>
              <p class="text-xs text-base-content/70">
                Quantidade de denúncias por dia (últimos {{ reportsPerDaySorted.length }} dias).
              </p>
            </div>
            <span v-if="dashboard.lastCityReported" class="badge badge-sm badge-outline">
              Última cidade: {{ dashboard.lastCityReported }}
            </span>
          </div>

          <div v-if="!reportsPerDaySorted.length" class="text-xs text-base-content/60">
            Ainda não há registros suficientes para exibir o gráfico.
          </div>

          <div v-else class="space-y-2 mt-2">
            <div
              v-for="day in reportsPerDaySorted"
              :key="day.date.toISOString()"
              class="flex items-center gap-2"
            >
              <div class="w-16 text-[11px] text-base-content/70">
                {{ formatShortDate(day.date) }}
              </div>

              <div class="flex-1">
                <div class="h-3 rounded-full bg-base-200 overflow-hidden">
                  <div
                    class="h-full rounded-full bg-primary"
                    :style="{ width: day.barWidth + '%' }"
                  ></div>
                </div>
              </div>

              <div class="w-10 text-right text-xs text-base-content">
                {{ day.reportCount }}
              </div>
            </div>
          </div>
        </div>

        <!-- Denúncias por cidade -->
        <div class="lg:col-span-2 space-y-3 bg-base-100 rounded-2xl shadow-sm p-4">
          <div class="flex items-center justify-between gap-2">
            <div>
              <h3 class="font-semibold text-base-content">Denúncias por cidade</h3>
              <p class="text-xs text-base-content/70">
                Ranking de cidades com maior volume de denúncias.
              </p>
            </div>
            <span class="badge badge-sm badge-outline">
              {{ formatNumber(dashboard.reportsPerCity.length) }} cidades
            </span>
          </div>

          <div v-if="!dashboard.reportsPerCity.length" class="text-xs text-base-content/60">
            Nenhuma cidade com denúncias registrada até o momento.
          </div>

          <div v-else class="mt-2 space-y-1 max-h-72 overflow-y-auto pr-1">
            <div
              v-for="(city, index) in reportsPerCitySorted"
              :key="city.city + index"
              class="flex items-center justify-between gap-2 py-1 px-2 rounded-lg hover:bg-base-200/70"
            >
              <div class="flex items-center gap-2">
                <span class="w-5 text-[11px] text-base-content/70"> #{{ index + 1 }} </span>
                <span class="text-xs font-medium">
                  {{ city.city }}
                </span>
              </div>

              <div class="flex items-center gap-2 text-xs">
                <span class="font-semibold">
                  {{ formatNumber(city.reportCount) }}
                </span>
                <span class="text-[11px] text-base-content/60"> denúncias </span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { apiClient } from '@/services/apiClient'

const loading = ref(true)
const error = ref(null)
const dashboard = ref({
  totalUsers: 0,
  activeUsers: 0,
  inactiveUsers: 0,
  totalPosts: 0,
  totalPostsToday: 0,
  totalComments: 0,
  totalReportCities: 0,
  mostActiveCity: '',
  lastCityReported: '',
  reportsPerDay: [],
  reportsPerCity: [],
})

const loadDashboard = async () => {
  loading.value = true
  error.value = null

  try {
    const res = await apiClient.get('api/admin/dashboard', { auth: true })
    const payload = res.data

    if (payload.statusCode !== 0 && payload.statusCode !== 200) {
      throw new Error(payload.message || 'Erro ao carregar dashboard.')
    }

    dashboard.value = payload.data || dashboard.value
  } catch (err) {
    console.error(err)
    error.value =
      err?.response?.data?.message || err?.message || 'Não foi possível carregar o dashboard.'
  } finally {
    loading.value = false
  }
}

onMounted(loadDashboard)

const formatNumber = (value) =>
  new Intl.NumberFormat('pt-BR', { maximumFractionDigits: 0 }).format(value || 0)

const formatShortDate = (date) =>
  date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })

const reportsPerDaySorted = computed(() => {
  if (!dashboard.value?.reportsPerDay?.length) return []

  const parsed = dashboard.value.reportsPerDay
    .map((item) => ({
      date: new Date(item.date),
      reportCount: item.reportCount ?? 0,
    }))
    .sort((a, b) => a.date - b.date)

  const maxCount = Math.max(...parsed.map((x) => x.reportCount), 0) || 1

  return parsed.map((x) => ({
    ...x,
    barWidth: Math.max((x.reportCount / maxCount) * 100, 5),
  }))
})

const reportsPerCitySorted = computed(() => {
  if (!dashboard.value?.reportsPerCity?.length) return []
  return [...dashboard.value.reportsPerCity].sort(
    (a, b) => (b.reportCount ?? 0) - (a.reportCount ?? 0),
  )
})
</script>
