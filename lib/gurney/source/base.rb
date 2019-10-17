module Gurney
  module Source
     class Base

       def present?
         raise NotImplementedError
       end

       def dependencies
         raise NotImplementedError
       end

     end
  end
end
