module QiniuHelper

  def last(prefix = '')
    ary = (0..9).to_a.reverse
    search = prefix
    result = nil

    while true do
      break result if result
      ary.each_with_index do |value, index|
        search.sub! /\d$/, value.to_s
        list = self.list(search)

        puts 'index: ' + index.to_s
        puts 'search: ' + search
        puts 'count: ' + list.size.to_s
        puts '-------------'

        if list.blank?
          next
        elsif list.size > 1
          search << '9'
          break
        elsif list.size == 1
          break result = list[0]['key']
        end
      end
    end

    result
  end

end