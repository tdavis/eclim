/**
 * Copyright (c) 2005 - 2006
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.eclim.command.taglist;

import org.eclim.command.CommandLine;
import org.eclim.command.OutputFilter;
import org.eclim.command.Options;

/**
 * Filter for tag list results.
 *
 * @author Eric Van Dewoestine (ervandew@yahoo.com)
 * @version $Revision$
 */
public class TaglistFilter
  implements OutputFilter
{
  /**
   * {@inheritDoc}
   */
  public String filter (CommandLine _commandLine, Object _result)
  {
    StringBuffer buffer = new StringBuffer();

    TagResult[] tags = (TagResult[])_result;
    for (int ii = 0; ii < tags.length; ii++){
      if(buffer.length() > 0){
        buffer.append('\n');
      }
      buffer.append(tags[ii].getName())
        .append('\t')
        .append(tags[ii].getFile())
        .append("\t/^").append(tags[ii].getPattern()).append("$/;\"")
        .append('\t')
        .append(tags[ii].getKind())
        .append("\tline:").append(tags[ii].getLine());
    }

    return buffer.toString();
  }
}
