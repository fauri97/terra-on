<template>
  <div class="space-y-6">
    <!-- Cabeçalho -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
      <div>
        <h2 class="text-2xl font-bold text-base-content">Usuários da plataforma</h2>
        <p class="text-sm text-base-content/70">
          Gerencie os usuários cadastrados, perfis de acesso e status de ativação.
        </p>
      </div>

      <div class="flex items-center gap-2">
        <button class="btn btn-ghost btn-sm" :disabled="store.loading" @click="store.fetchAll">
          <span class="material-symbols-outlined text-sm">refresh</span>
          Atualizar
        </button>
      </div>
    </div>

    <!-- Estados globais -->
    <div v-if="store.loading" class="w-full flex justify-center py-10">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <div v-else-if="store.error" class="alert alert-error text-sm">
      <span>{{ store.error }}</span>
    </div>

    <!-- Tabela -->
    <div v-else class="card bg-base-100 shadow-sm">
      <div class="card-body p-4 md:p-6 space-y-4">
        <!-- Filtros simples -->
        <div class="flex flex-col md:flex-row gap-3 md:items-center md:justify-between">
          <div class="flex flex-wrap gap-2 text-xs md:text-sm">
            <span class="badge badge-outline"> Total: {{ store.items.length }} </span>
            <span class="badge badge-success badge-outline"> Ativos: {{ store.activeCount }} </span>
            <span class="badge badge-outline"> Inativos: {{ store.inactiveCount }} </span>
          </div>

          <div class="flex gap-2">
            <select v-model="roleFilter" class="select select-bordered select-xs md:select-sm">
              <option value="">Todos os perfis</option>
              <option value="Admin">Admin</option>
              <option value="Gov">Gov</option>
              <option value="User">User</option>
            </select>
            <input
              v-model="search"
              type="text"
              placeholder="Buscar por nome ou e-mail"
              class="input input-bordered input-xs md:input-sm w-40 md:w-64"
            />
          </div>
        </div>

        <!-- Tabela responsiva -->
        <div class="overflow-x-auto">
          <table class="table table-zebra table-sm md:table-md">
            <thead>
              <tr class="text-xs">
                <th></th>
                <th>Nome</th>
                <th class="hidden md:table-cell">Cidade / UF</th>
                <th class="hidden md:table-cell">Telefone</th>
                <th>Perfil</th>
                <th>Status</th>
                <th class="text-right">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in filteredUsers" :key="user.id" class="align-middle">
                <!-- Avatar -->
                <td>
                  <div class="avatar">
                    <div
                      class="w-9 rounded-full bg-base-200 border border-base-300 overflow-hidden"
                    >
                      <img v-if="getAvatarSrc(user)" :src="getAvatarSrc(user)" :alt="user.name" />
                      <div
                        v-else
                        class="w-full h-full flex items-center justify-center text-[11px] font-semibold text-base-content/70"
                      >
                        {{ getInitials(user.name) }}
                      </div>
                    </div>
                  </div>
                </td>

                <!-- Nome + email -->
                <td>
                  <div class="flex flex-col">
                    <span class="font-medium text-sm leading-tight">
                      {{ user.name }}
                    </span>
                    <span class="text-[11px] text-base-content/60 truncate max-w-[200px]">
                      {{ user.email }}
                    </span>
                  </div>
                </td>

                <!-- Cidade / UF -->
                <td class="hidden md:table-cell">
                  <div class="text-xs">
                    <span v-if="user.city">{{ user.city }}</span>
                    <span v-if="user.city && user.state"> · </span>
                    <span v-if="user.state" class="text-base-content/70">{{ user.state }}</span>
                    <span v-if="!user.city && !user.state" class="text-base-content/50">
                      Não informado
                    </span>
                  </div>
                </td>

                <!-- Telefone -->
                <td class="hidden md:table-cell">
                  <span class="text-xs text-base-content/80">
                    {{ user.phoneNumber || 'Não informado' }}
                  </span>
                </td>

                <!-- Role -->
                <td>
                  <span class="badge badge-xs md:badge-sm" :class="roleBadgeClass(user.role)">
                    {{ user.role || 'User' }}
                  </span>
                </td>

                <!-- Status (usando isDeactivated invertido) -->
                <td>
                  <span
                    class="badge badge-xs md:badge-sm"
                    :class="!user.isDeactivated ? 'badge-success' : 'badge-ghost'"
                  >
                    {{ !user.isDeactivated ? 'Ativo' : 'Inativo' }}
                  </span>
                </td>

                <!-- Ações -->
                <td class="text-right">
                  <div class="flex justify-end gap-1">
                    <button type="button" class="btn btn-ghost btn-xs" @click="openEdit(user)">
                      <span class="material-symbols-outlined text-sm">edit</span>
                      Editar
                    </button>

                    <button
                      type="button"
                      class="btn btn-outline btn-xs"
                      :class="!user.isDeactivated ? 'btn-error' : 'btn-success'"
                      :disabled="store.toggling[user.id]"
                      @click="toggleUser(user)"
                    >
                      <span
                        v-if="!store.toggling[user.id]"
                        class="material-symbols-outlined text-sm"
                      >
                        {{ !user.isDeactivated ? 'block' : 'check_circle' }}
                      </span>
                      <span v-else class="loading loading-spinner loading-xs"></span>
                      <span class="hidden md:inline">
                        {{ !user.isDeactivated ? 'Desativar' : 'Ativar' }}
                      </span>
                    </button>
                  </div>
                </td>
              </tr>

              <tr v-if="!filteredUsers.length">
                <td colspan="7" class="text-center text-xs text-base-content/60 py-6">
                  Nenhum usuário encontrado para os filtros informados.
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal de edição separado -->
    <UserEditModal
      :open="showEditModal"
      :user="selectedUser"
      :saving="store.saving"
      @close="closeEdit"
      @save="handleSaveUser"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useUsersStore } from '@/stores/users'
import UserEditModal from '@/components/users/UserEditModal.vue'

const store = useUsersStore()

const search = ref('')
const roleFilter = ref('')

const showEditModal = ref(false)
const selectedUser = ref(null)

onMounted(() => {
  store.fetchAll()
})

const filteredUsers = computed(() => {
  let list = [...store.items]

  if (roleFilter.value) {
    list = list.filter((u) => (u.role || 'User').toLowerCase() === roleFilter.value.toLowerCase())
  }

  if (search.value) {
    const term = search.value.toLowerCase()
    list = list.filter(
      (u) => u.name?.toLowerCase().includes(term) || u.email?.toLowerCase().includes(term),
    )
  }

  return list
})

const getAvatarSrc = (user) => {
  const b64 = user?.base64ProfileImage
  if (!b64) return null
  if (b64.startsWith('data:')) return b64
  return `data:image/png;base64,${b64}`
}

const getInitials = (name) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase()
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
}

const roleBadgeClass = (role) => {
  switch (role) {
    case 'Admin':
      return 'badge-primary'
    case 'Gov':
      return 'badge-info'
    default:
      return 'badge-ghost'
  }
}

const openEdit = (user) => {
  selectedUser.value = user
  showEditModal.value = true
}

const closeEdit = () => {
  showEditModal.value = false
  selectedUser.value = null
}

const handleSaveUser = async (payload) => {
  try {
    await store.updateUser(payload.id, {
      name: payload.name,
      phoneNumber: payload.phoneNumber,
      city: payload.city,
      state: payload.state,
      base64ProfileImage: payload.base64ProfileImage,
      role: payload.role,
    })
    closeEdit()
  } catch (err) {
    alert(err?.response?.data?.message || err?.message || 'Não foi possível salvar as alterações.')
  }
}

const toggleUser = async (user) => {
  try {
    await store.setActive(user.id)
  } catch (err) {
    alert(
      err?.response?.data?.message ||
        err?.message ||
        'Não foi possível alterar o status do usuário.',
    )
  }
}
</script>
