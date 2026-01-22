require 'rails_helper'

RSpec.describe 'Tasks API', type: :request do
  let(:genre) { Genre.create!(name: 'テスト用ジャンル') }

  describe 'POST /tasks' do
    context 'priorityパラメータを指定した場合' do
      it 'priorityを指定してタスクを作成できること' do
        expect {
          post '/tasks', params: {
            name: 'テストタスク',
            explanation: '説明文',
            genreId: genre.id,
            priority: 'high'
          }
        }.to change(Task, :count).by(1)

        created_task = Task.last
        expect(created_task.priority).to eq 'high'
      end

      it 'レスポンスJSONに作成されたタスクのpriorityが含まれていること' do
        post '/tasks', params: {
          name: 'テストタスク',
          explanation: '説明文',
          genreId: genre.id,
          priority: 'high'
        }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)

        # レスポンスは全タスク一覧なので、作成したタスクを探す
        created_task = json_response.find { |task| task['name'] == 'テストタスク' }
        expect(created_task).not_to be_nil
        expect(created_task['priority']).to eq 'high'
      end
    end

    context 'priorityパラメータを指定しない場合' do
      it 'デフォルト値「medium」でタスクが作成されること' do
        post '/tasks', params: {
          name: 'デフォルトテスト',
          explanation: '説明文',
          genreId: genre.id
        }

        created_task = Task.last
        expect(created_task.priority).to eq 'medium'
      end

      it 'レスポンスJSONにデフォルトのpriorityが含まれていること' do
        post '/tasks', params: {
          name: 'デフォルトテスト',
          explanation: '説明文',
          genreId: genre.id
        }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)

        created_task = json_response.find { |task| task['name'] == 'デフォルトテスト' }
        expect(created_task).not_to be_nil
        expect(created_task['priority']).to eq 'medium'
      end
    end
  end

  describe 'GET /tasks' do
    before do
      Task.create!(name: '低優先度タスク', genre: genre, priority: :low)
      Task.create!(name: '中優先度タスク', genre: genre, priority: :medium)
      Task.create!(name: '高優先度タスク', genre: genre, priority: :high)
    end

    it 'タスク一覧のレスポンスJSONに各タスクのpriorityが含まれていること' do
      get '/tasks'

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      low_task = json_response.find { |task| task['name'] == '低優先度タスク' }
      medium_task = json_response.find { |task| task['name'] == '中優先度タスク' }
      high_task = json_response.find { |task| task['name'] == '高優先度タスク' }

      expect(low_task['priority']).to eq 'low'
      expect(medium_task['priority']).to eq 'medium'
      expect(high_task['priority']).to eq 'high'
    end
  end
end
