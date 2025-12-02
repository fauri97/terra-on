<template>
  <div class="space-y-6">
    <!-- Cabeçalho -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
      <div>
        <h2 class="text-2xl font-bold text-base-content">Denúncias de posts</h2>
        <p class="text-sm text-base-content/70">
          Visualize e acompanhe as denúncias feitas em posts da plataforma TerraON.
        </p>
      </div>

      <div class="flex items-center gap-2">
        <button
          class="btn btn-ghost btn-sm"
          :disabled="store.loading"
          @click="refresh"
        >
          <span class="material-symbols-outlined text-sm">refresh</span>
          Atualizar
        </button>
      </div>
    </div>

    <!-- Estados globais -->
    <div v-if="store.loading && !store.items.length" class="w-full flex justify-center py-10">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <div v-else-if="store.error && !store.items.length" class="alert alert-error text-sm">
      <span>{{ store.error }}</span>
    </div>

    <!-- Tabela -->
    <div v-else class="card bg-base-100 shadow-sm">
      <div class="card-body p-4 md:p-6 space-y-4">
        <!-- Filtros -->
        <div class="flex flex-col md:flex-row gap-3 md:items-center md:justify-between">
          <div class="flex flex-wrap gap-2 text-xs md:text-sm">
            <span class="badge badge-outline">
              Total: {{ filteredReports.length }}
            </span>
          </div>

          <div class="flex flex-wrap gap-2">
            <select
              v-model="statusFilter"
              class="select select-bordered select-xs md:select-sm"
            >
              <option value="">Todos os status</option>
              <option
                v-for="status in statusOptions"
                :key="status"
                :value="status"
              >
                {{ status }}
              </option>
            </select>

            <input
              v-model="search"
              type="text"
              placeholder="Buscar por descrição, usuário ou motivo"
              class="input input-bordered input-xs md:input-sm w-48 md:w-72"
            />
          </div>
        </div>

        <!-- Tabela responsiva -->
        <div class="overflow-x-auto">
          <table class="table table-zebra table-sm md:table-md">
            <thead>
              <tr class="text-xs">
                <th>ID</th>
                <th>Post</th>
                <th>Usuário</th>
                <th class="hidden md:table-cell">Motivo</th>
                <th>Status</th>
                <th class="hidden md:table-cell">Imagens</th>
                <th class="text-right">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in paginatedReports"
                :key="item.id"
                class="align-middle"
              >
                <td class="text-xs text-base-content/80">
                  #{{ item.id }}
                </td>

                <!-- Post / descrição -->
                <td>
                  <div class="max-w-xs">
                    <p class="text-xs font-medium text-base-content">
                      Post #{{ item.reportId }}
                    </p>
                    <p class="text-[11px] text-base-content/70 line-clamp-2">
                      {{ item.reportDescription || 'Sem descrição' }}
                    </p>
                  </div>
                </td>

                <!-- Usuário -->
                <td>
                  <div class="flex flex-col">
                    <span class="text-xs font-semibold">
                      {{ item.userName }}
                    </span>
                    <span class="text-[11px] text-base-content/60">
                      ID usuário: {{ item.userId }}
                    </span>
                  </div>
                </td>

                <!-- Motivo -->
                <td class="hidden md:table-cell">
                  <span class="text-xs text-base-content/80 line-clamp-2">
                    {{ item.reason || '-' }}
                  </span>
                </td>

                <!-- Status -->
                <td>
                  <span
                    class="badge badge-xs md:badge-sm"
                    :class="statusBadgeClass(item.status)"
                  >
                    {{ item.status || 'Não definido' }}
                  </span>
                </td>

                <!-- Imagens (info) -->
                <td class="hidden md:table-cell">
                  <span
                    v-if="item.imagesBase64 && item.imagesBase64.length"
                    class="badge badge-outline badge-xs md:badge-sm"
                  >
                    {{ item.imagesBase64.length }} imagem(ns)
                  </span>
                  <span
                    v-else
                    class="text-[11px] text-base-content/50"
                  >
                    Sem imagens
                  </span>
                </td>

                <!-- Ações -->
                <td class="text-right">
                  <div class="flex flex-col items-end gap-1">
                    <!-- controles de status -->
                    <div class="flex flex-wrap justify-end gap-1">
                      <button
                        type="button"
                        class="btn btn-ghost btn-xs"
                        :class="isCurrentStatus(item, 'Pendente') ? 'btn-primary btn-outline' : 'btn-ghost'"
                        :disabled="store.isUpdating?.(item.id)"
                        @click="changeStatus(item, 'Pendente')"
                      >
                        Pendente
                      </button>
                      <button
                        type="button"
                        class="btn btn-ghost btn-xs"
                        :class="isCurrentStatus(item, 'Revisado') ? 'btn-primary btn-outline' : 'btn-ghost'"
                        :disabled="store.isUpdating?.(item.id)"
                        @click="changeStatus(item, 'Revisado')"
                      >
                        Revisado
                      </button>
                      <button
                        type="button"
                        class="btn btn-ghost btn-xs"
                        :class="isCurrentStatus(item, 'Recusado') ? 'btn-primary btn-outline' : 'btn-ghost'"
                        :disabled="store.isUpdating?.(item.id)"
                        @click="changeStatus(item, 'Recusado')"
                      >
                        Recusado
                      </button>

                      <span
                        v-if="store.isUpdating?.(item.id)"
                        class="text-[10px] ml-1 italic text-base-content/60"
                      >
                        salvando...
                      </span>
                    </div>

                    <!-- botão ver imagens -->
                    <div class="flex justify-end gap-1">
                      <button
                        type="button"
                        class="btn btn-ghost btn-xs"
                        :disabled="!item.imagesBase64?.length"
                        @click="openImages(item)"
                      >
                        <span class="material-symbols-outlined text-sm">
                          imagesmode
                        </span>
                        <span class="hidden md:inline">Ver imagens</span>
                      </button>
                    </div>
                  </div>
                </td>
              </tr>

              <tr v-if="!filteredReports.length">
                <td colspan="7" class="text-center text-xs text-base-content/60 py-6">
                  Nenhuma denúncia encontrada para os filtros informados.
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginação client-side -->
        <div
          v-if="filteredReports.length > pageSize"
          class="flex items-center justify-between pt-2 text-xs"
        >
          <div class="text-base-content/60">
            Página {{ uiPage }} de {{ totalPages }}
          </div>

          <div class="flex items-center gap-1">
            <button
              class="btn btn-xs"
              :disabled="uiPage === 1"
              @click="prevUiPage"
            >
              <span class="material-symbols-outlined text-sm">
                chevron_left
              </span>
            </button>
            <button
              class="btn btn-xs"
              :disabled="uiPage === totalPages"
              @click="nextUiPage"
            >
              <span class="material-symbols-outlined text-sm">
                chevron_right
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de imagens -->
    <dialog v-if="imageModal.open" class="modal modal-open">
      <div class="modal-box max-w-2xl">
        <h3 class="font-bold text-lg mb-1">
          Imagens da denúncia #{{ imageModal.item?.id }}
        </h3>
        <p class="text-xs text-base-content/60 mb-4">
          Post #{{ imageModal.item?.reportId }} · {{ imageModal.item?.userName }}
        </p>

        <div v-if="currentImage" class="space-y-2">
          <div class="relative">
            <div class="overflow-hidden rounded-xl border border-base-300 bg-base-200">
              <img
                :src="currentImage"
                alt="Imagem denúncia"
                class="w-full max-h-[480px] object-contain"
              />
            </div>

            <button
              v-if="imageModal.item?.imagesBase64?.length > 1"
              type="button"
              class="btn btn-circle btn-xs absolute left-2 top-1/2 -translate-y-1/2"
              @click="prevImage"
            >
              <span class="material-symbols-outlined text-sm">chevron_left</span>
            </button>

            <button
              v-if="imageModal.item?.imagesBase64?.length > 1"
              type="button"
              class="btn btn-circle btn-xs absolute right-2 top-1/2 -translate-y-1/2"
              @click="nextImage"
            >
              <span class="material-symbols-outlined text-sm">chevron_right</span>
            </button>
          </div>

          <!-- indicadores -->
          <div
            v-if="imageModal.item?.imagesBase64?.length > 1"
            class="flex justify-center gap-1 mt-1"
          >
            <button
              v-for="(_, idx) in imageModal.item?.imagesBase64 || []"
              :key="idx"
              type="button"
              class="h-1.5 rounded-full transition-all"
              :class="imageModal.index === idx ? 'w-4 bg-primary' : 'w-2 bg-base-300'"
              @click="imageModal.index = idx"
            ></button>
          </div>
        </div>

        <div v-else class="text-sm text-base-content/60">
          Nenhuma imagem disponível.
        </div>

        <div class="modal-action mt-4">
          <button type="button" class="btn btn-ghost btn-sm" @click="closeImages">
            Fechar
          </button>
        </div>
      </div>

      <form method="dialog" class="modal-backdrop" @click="closeImages">
        <button>close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { usePostReportsStore } from '@/stores/postReports'

const store = usePostReportsStore()

const search = ref('')
const statusFilter = ref('')

const uiPage = ref(1)
const pageSize = 10

const imageModal = reactive({
  open: false,
  item: null,
  index: 0,
})

onMounted(() => {
  store.fetchAll()
})

const statusOptions = computed(() => store.statusOptions)

const filteredReports = computed(() => {
  let list = [...store.items]

  if (statusFilter.value) {
    list = list.filter((x) => x.status === statusFilter.value)
  }

  if (search.value) {
    const term = search.value.toLowerCase()
    list = list.filter(
      (x) =>
        x.reportDescription?.toLowerCase().includes(term) ||
        x.userName?.toLowerCase().includes(term) ||
        x.reason?.toLowerCase().includes(term),
    )
  }

  return list
})

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredReports.value.length / pageSize)),
)

const paginatedReports = computed(() => {
  const start = (uiPage.value - 1) * pageSize
  return filteredReports.value.slice(start, start + pageSize)
})

const prevUiPage = () => {
  if (uiPage.value > 1) uiPage.value -= 1
}

const nextUiPage = () => {
  if (uiPage.value < totalPages.value) uiPage.value += 1
}

const refresh = async () => {
  uiPage.value = 1
  await store.fetchAll()
}

const statusBadgeClass = (status) => {
  if (!status) return 'badge-ghost'

  const s = status.toLowerCase()

  if (s.includes('pend')) return 'badge-warning'
  if (s.includes('anal') || s.includes('rev')) return 'badge-info'
  if (s.includes('aprov') || s.includes('ok') || s.includes('ativo')) return 'badge-success'
  if (s.includes('recus') || s.includes('bloq') || s.includes('ban')) return 'badge-error'

  return 'badge-ghost'
}

const isCurrentStatus = (item, label) => {
  const current = (item.status ?? '').toString().toLowerCase()
  const target = label.toLowerCase()
  return current.includes(target.slice(0, 4))
}

const changeStatus = (item, label) => {
  const map = {
    Pendente: 'pendente',
    Revisado: 'revisado',
    Recusado: 'recusado',
  }

  const newStatus = map[label] ?? label.toLowerCase()
  store.updateStatus(item.id, newStatus)
}

const openImages = (item) => {
  if (!item || !item.imagesBase64 || !item.imagesBase64.length) return
  imageModal.open = true
  imageModal.item = item
  imageModal.index = 0
}

const closeImages = () => {
  imageModal.open = false
  imageModal.item = null
  imageModal.index = 0
}

const currentImage = computed(() => {
  if (!imageModal.open || !imageModal.item?.imagesBase64?.length) return null
  const list = imageModal.item.imagesBase64
  const idx = imageModal.index ?? 0
  const base64 = list[idx]
  if (!base64) return null

  // Assume base64 sem prefixo, adiciona data URL
  if (base64.startsWith('data:')) return base64
  return `data:image/jpeg;base64,${base64}`
})

const nextImage = () => {
  if (!imageModal.item?.imagesBase64?.length) return
  const total = imageModal.item.imagesBase64.length
  imageModal.index = (imageModal.index + 1) % total
}

const prevImage = () => {
  if (!imageModal.item?.imagesBase64?.length) return
  const total = imageModal.item.imagesBase64.length
  imageModal.index = (imageModal.index - 1 + total) % total
}
</script>
