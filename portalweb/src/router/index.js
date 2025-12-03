import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/views/LoginView.vue'
import AdminDashboardView from '@/views/AdminDashboardView.vue'
import PortalLayout from '@/layouts/AdminPortalLayout.vue'
import { useAuthStore } from '@/stores/auth'
import AdminUsersView from '@/views/AdminUsersView.vue'
import ReportsFeedView from '@/views/ReportsFeedView.vue'
import PostReportView from '@/views/AdminPostReportsView.vue'
import ReportsExportPage from '@/views/ReportsExportPage.vue'

const AdminSettingsView = { template: '<div>Configurações (em breve)</div>' }

const routes = [
  {
    path: '/',
    name: 'login',
    component: LoginView,
    meta: {
      guestOnly: true,
      title: 'Login | TerraON',
    },
  },
  {
    path: '/admin',
    component: PortalLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard',
        component: AdminDashboardView,
        meta: { requiresAuth: true, title: 'Dashboard | TerraON' },
      },
      {
        path: 'reports',
        name: 'reports',
        component: ReportsFeedView,
        meta: { requiresAuth: true, title: 'Denúncias | TerraON' },
      },
      {
        path: 'post-reports',
        name: 'post-reports',
        component: PostReportView,
        meta: { requiresAuth: true, title: 'Denúncias de Posts | TerraON' },
      },
      {
        path: 'users',
        name: 'users',
        component: AdminUsersView,
        meta: { requiresAuth: true, title: 'Usuários | TerraON' },
      },
      {
        path: '/admin/reports/export',
        name: 'ReportsExport',
        component: ReportsExportPage,
        meta: { requiresAuth: true, title: 'Relatórios | TerraON' },
      },
      {
        path: 'settings',
        name: 'settings',
        component: AdminSettingsView,
        meta: { requiresAuth: true, title: 'Configurações | TerraON' },
      },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: {
      template: `
        <div class="min-h-screen flex items-center justify-center bg-base-200">
          <div class="text-center space-y-4">
            <h1 class="text-3xl font-bold text-primary">404</h1>
            <p class="text-base-content/70">Página não encontrada.</p>
            <router-link to="/" class="btn btn-primary btn-sm mt-2">
              Ir para o início
            </router-link>
          </div>
        </div>
      `,
    },
    meta: {
      title: '404 | TerraON',
    },
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const isLoggedIn = authStore.isAuthenticated

  if (to.meta?.title) {
    document.title = to.meta.title
  } else {
    document.title = 'TerraON Portal'
  }

  if (to.meta.requiresAuth && !isLoggedIn) {
    return next({
      name: 'login',
      query: { redirect: to.fullPath },
    })
  }

  if (to.meta.guestOnly && isLoggedIn) {
    return next({ name: 'dashboard' })
  }

  return next()
})

export default router
