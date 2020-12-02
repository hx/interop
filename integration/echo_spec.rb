require 'open3'

describe 'Integration' do
  apps = {
    golang: 'go run golang/echo.go',
    ruby:   'ruby ruby/echo.rb'
  }

  combinations = <<~TEXT
    golang
    golang golang
    golang golang golang
    ruby
    ruby ruby
    ruby ruby ruby
    golang ruby
    ruby golang
    ruby golang ruby
    golang ruby golang
    golang ruby golang ruby golang
  TEXT

  describe 'the echo app chain with' do
    combinations.lines.each do |line|
      example line.gsub(' ', '/') do
        calls = line.scan(/\w+/).map.with_index { |name, i| ["#{i + 1}.#{name}", apps[name.to_sym]] }.to_h

        errs_top    = []
        errs_bottom = []
        calls.keys.each.with_index do |name, index|
          errs_top << "#{name} init"
          errs_top << "#{name} dig" unless index.zero?
          errs_top << "#{name} calling"

          unless index.zero?
            errs_bottom << "#{name} done"
            errs_bottom << "#{name} trigger"
          end
          errs_bottom << "#{name} handle #{calls.to_a[index + 1].first}" unless index == calls.length - 1
        end

        errs = (errs_top + errs_bottom.reverse).join("\n") << "\n"

        cmd = calls.each_with_object [] do |(name, exe), c|
          c << exe
          c << '--main' if c.one?
          c << name
        end.join(' ')

        # TODO: assert JSON output on STDOUT
        _o, e, s = Open3.capture3(cmd)
        expect(e).to eq errs
        expect(s).to be_success
      end
    end
  end
end
