<template>
  <div class="max-w-3xl mx-auto space-y-6">
    <!-- Cabeçalho -->
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-2xl font-bold text-base-content">Exportar relatórios de denúncias</h2>
        <p class="text-sm text-base-content/70">
          Gere relatórios em PDF das denúncias registradas na plataforma TerraON para envio à
          prefeitura ou órgãos de fiscalização.
        </p>
      </div>
    </div>

    <!-- Card de filtros -->
    <div class="card bg-base-100 shadow-sm border border-base-200">
      <div class="card-body space-y-4">
        <h3 class="font-semibold text-base-content">Filtros</h3>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Cidade -->
          <div class="form-control">
            <label class="label">
              <span class="label-text text-xs md:text-sm">Cidade</span>
            </label>
            <input
              v-model="city"
              type="text"
              placeholder="Ex.: Taquari"
              class="input input-bordered input-sm w-full"
            />
            <label class="label">
              <span class="label-text-alt text-[10px] text-base-content/60">
                Se vazio, serão consideradas todas as cidades.
              </span>
            </label>
          </div>

          <!-- Status -->
          <div class="form-control">
            <label class="label">
              <span class="label-text text-xs md:text-sm">Status</span>
            </label>
            <select v-model="status" class="select select-bordered select-sm w-full">
              <option value="">Todos os status</option>
              <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">
                {{ opt.label }}
              </option>
            </select>
            <label class="label">
              <span class="label-text-alt text-[10px] text-base-content/60">
                Se vazio, serão considerados todos os status.
              </span>
            </label>
          </div>

          <!-- Data inicial -->
          <div class="form-control">
            <label class="label">
              <span class="label-text text-xs md:text-sm">Data inicial</span>
            </label>
            <input v-model="from" type="date" class="input input-bordered input-sm w-full" />
          </div>

          <!-- Data final -->
          <div class="form-control">
            <label class="label">
              <span class="label-text text-xs md:text-sm">Data final</span>
            </label>
            <input v-model="to" type="date" class="input input-bordered input-sm w-full" />
          </div>
        </div>

        <!-- Aviso -->
        <div class="alert alert-info py-2 px-3 text-xs mt-2">
          <span class="material-symbols-outlined text-sm mr-1">info</span>
          <span>
            Se nenhum filtro for informado, o relatório trará todas as denúncias disponíveis no
            sistema para o seu usuário.
          </span>
        </div>

        <!-- Mensagens de erro -->
        <div v-if="error" class="alert alert-error text-xs mt-2">
          <span>{{ error }}</span>
        </div>

        <!-- Ações -->
        <div class="flex items-center justify-end gap-2 pt-2">
          <button
            type="button"
            class="btn btn-ghost btn-sm"
            :disabled="loading"
            @click="clearFilters"
          >
            Limpar filtros
          </button>

          <button
            type="button"
            class="btn btn-primary btn-sm gap-1"
            :class="{ loading }"
            :disabled="loading"
            @click="downloadPdf"
          >
            <span v-if="!loading" class="material-symbols-outlined text-sm"> picture_as_pdf </span>
            <span v-if="!loading">Baixar PDF</span>
            <span v-else>Gerando PDF...</span>
          </button>
        </div>
      </div>
    </div>

    <div class="text-[11px] text-base-content/60">
      O arquivo gerado pode ser anexado a ofícios, processos administrativos ou compartilhado
      diretamente com as prefeituras parceiras.
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { apiClient } from '@/services/apiClient'

const status = ref('')
const city = ref('')
const from = ref('')
const to = ref('')

const loading = ref(false)
const error = ref(null)

const statusOptions = [
  { value: 'pending', label: 'Pendente' },
  { value: 'inprogress', label: 'Em andamento' },
  { value: 'resolved', label: 'Resolvido' },
  { value: 'inappropriate', label: 'Inapropriado' },
  { value: 'dismissed', label: 'Descartado' },
  { value: 'diactivated', label: 'Desativado' },
]

const clearFilters = () => {
  status.value = ''
  city.value = ''
  from.value = ''
  to.value = ''
  error.value = null
}

const downloadPdf = async () => {
  error.value = null

  try {
    loading.value = true

    const params = {}

    if (status.value) params.status = status.value
    if (city.value) params.city = city.value
    if (from.value) params.from = from.value
    if (to.value) params.to = to.value

    // monta a querystring só pra logar a URL final
    const searchParams = new URLSearchParams()
    Object.entries(params).forEach(([key, val]) => {
      if (val != null && val !== '') {
        searchParams.append(key, val)
      }
    })

    const qs = searchParams.toString()
    const debugUrl = qs
      ? `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:5078/'}api/report/export/pdf?${qs}`
      : `${import.meta.env.VITE_API_BASE_URL || 'http://localhost:5078/'}api/report/export/pdf`

    console.log('URL de download do PDF (debug):', debugUrl)
    console.log('Params enviados:', params)

    const res = await apiClient.get('api/report/export/pdf', {
      auth: true,
      params,
      responseType: 'blob', // 👈 AGORA isso chega no Axios
    })

    const blob = new Blob([res.data], { type: 'application/pdf' })

    let fileName = 'relatorios-denuncias.pdf'
    const disposition = res.headers?.['content-disposition'] || res.headers?.['Content-Disposition']

    if (disposition) {
      const fileNameStarMatch = disposition.match(/filename\*\s*=\s*UTF-8''([^;]+)/i)
      if (fileNameStarMatch && fileNameStarMatch[1]) {
        try {
          fileName = decodeURIComponent(fileNameStarMatch[1])
        } catch {
          fileName = fileNameStarMatch[1]
        }
      } else {
        const fileNameMatch = disposition.match(/filename="?([^";]+)"?/i)
        if (fileNameMatch && fileNameMatch[1]) {
          fileName = fileNameMatch[1]
        }
      }
    }

    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = fileName
    document.body.appendChild(a)
    a.click()
    a.remove()
    window.URL.revokeObjectURL(url)
  } catch (err) {
    console.error(err)
    error.value =
      err?.response?.data?.message || err?.message || 'Não foi possível gerar o relatório em PDF.'
  } finally {
    loading.value = false
  }
}
</script>
