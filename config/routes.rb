Rails.application.routes.draw do
  devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }
  get 'order/index'

#  get 'users/new'
  resources :users
  # patch '/users/:id/' => 'users#show'
  # get 'users' => 'users#index'

  resources :customers
  get 'qbwc/action' => 'qbwc#_generate_wsdl'
  get 'qbwc/qwc' => 'qbwc#qwc'
  wash_out :qbwc
  root 'dashboard#index'
  
  # resources :sessions

  # delete 'logout' => 'sessions#destroy'
  # get 'signin' => 'sessions#new'

  get :search, controller: :dashboard
    
  resources :orders do resources :comments end
  get 'wds' => 'orders#wds'
  get 'art' => 'orders#art'
  get 'admin' => 'orders#admin'
  
  resources :items
  resources :sites
  resources :site_inventories
  resources :bills
  resources :trackings
  resources :invoices
  resources :accounts
  resources :credit_memos

  
  resources :notifications do
    collection do
      post :mark_as_read
    end
  end

  get '/email_send' => 'trackings#email_send'
    
  get '/customer_details' => 'orders#customer_details'

  get '/dashboard' => 'dashboard#index'
  
    
#  delete 'docs/:id'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
